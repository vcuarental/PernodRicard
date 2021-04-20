@isTest
public class ASI_MFM_CN_POSM_MassUpload_Test {
    private static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;

        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
    public testMethod static void testMassUpload(){
        
        ASI_MFM_Budget__c a = ASI_MFM_CAP_TestClassHelper.createBudget();      
        
        List<ASI_MFM_Prefix__c> pList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px1);
		ASI_MFM_Prefix__c px2= new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px2);
        insert pList; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
		List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr1);
		ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr2);
        insert prList;
        
		ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=px2.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
				ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=userInfo.getUserId(),ASI_MFM_Status__c='Final');
		insert plan;
			
		ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Plan__c = plan.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO'), name='test', ASI_MFM_PO_End_Date__c=Date.today(), ASI_MFM_PO_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft', ASI_MFM_Prefix__c=px1.id);
		insert po;
        
        
        test.startTest();
        /*
        ASI_MFM_CN_POSM_MassUploadByBatchCls controller = new ASI_MFM_CN_POSM_MassUploadByBatchCls();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName ='ASI_MFM_Stock_In_Request__c';
        controller.parentID ='';
        controller.parentField ='';
        controller.fields ='ASI_MFM_PO_POSM_Line_Number__c,ASI_MFM_Lot_Number__c,ASI_MFM_PO_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        controller.fieldsLabel ='PO POSM Line Number,Lot Number,PO Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        //controller.fields ='ASI_MFM_Lot_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        //controller.fieldsLabel ='Lot Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        controller.lookupEXID ='ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        controller.template ='';
        controller.template2 ='';
        controller.report='';
        controller.recordtypeName ='CN Stock In Request';
        controller.currentPageURL =''; // v
        controller.inlineVF =true;
        controller.reloadNeeded =true;
        controller.defaultValues ='';
        controller.recEXID ='External ID';
        controller.recEXIDcol =''; 
        controller.parentObjectAPIName ='ASI_MFM_Mass_Upload_Log__c';
        controller.ParentObjectUploadMsg ='ASI_MFM_Error_Message__c';
        controller.upsertMode =false;
        controller.batchMode =false;
        controller.opt_allOrNone=true;    
        controller.emailNotification =true;
        controller.monitorFieldName ='ASI_MFM_PO_Number__c';
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('PO POSM Line Number,送货地点,批次号,PO Number,Item Group Code,单件重量(祼重KG),外箱体积(M3),外箱毛重(KG),最小计量单位单价(RMB),总件数,分批送货数量,每箱有几个大袋/大盒,每大袋/大盒里几个小件,每箱中几个小件,零头箱中礼品件数,产品总箱数(不含零头箱),分批送货日期(YYYYMMDD)x\rPPL-18000017,88酒吧(ONSHA1247),,22180058,X1MLEGT17001,1,1,1,1,11,1,1,1,1,1,1,20181010');
        controller.uploadcsv();        
        
        //Test inLineVF is false;
        controller.inlineVF = false;
        controller.uploadcsv();
            */

        
        
        ASI_MFM_CN_POSM_MassUploadByBatchCls controller = new ASI_MFM_CN_POSM_MassUploadByBatchCls();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';
        controller.emailNotification = true;
        controller.recordtypeName = 'CN Stock In Request';
        controller.fields = 'ASI_MFM_PO_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Length__c,ASI_MFM_SIR_Sent__c,ASI_Delivery_Date__c,ASI_MFM_Width__c,ASI_MFM_Qty_Per_Box__c';
        controller.fieldsLabel = 'PO Number,Weight/Unit(KG),Case Size(M3),Length,Sent,Date,Width,QtyBox';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.lookupEXID ='ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        controller.currentPageURL = String.valueof(a.id);
        controller.monitorFieldName ='ASI_MFM_PO_Number__c';
        controller.inlineVF = false;
        controller.upsertMode = false;
        controller.DefaultValues = '';
        controller.init();
        controller.upsertMode = false;
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('PO Number,Weight/Unit(KG),Case Size(M3),Length,Sent,Date,Width,QtyBox\rtest,220,420,1,y,20181010,1.11,10');
        controller.uploadcsv();        
        String tmp = controller.monitorValue;
        
        //Test inLineVF is false;
        controller.inlineVF = false;
        controller.uploadcsv();

        
        
        //Test negative case - Wrong field name mapping
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';        
        controller.recordtypeName = 'CN Stock In Request';
        controller.fields = 'ASI_MFM_Lot_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        //controller.fieldsLabel = 'Lot Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        //controller.lookupEXID = 'ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        controller.fields = 'ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c';
        controller.fieldsLabel = 'Weight/Unit(KG),Case Size(M3)';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.upsertMode = false;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('name_Error,NumberOfEmployees_Error,AnnualRevenue_Error\rJohn,Error,Error,Test_TooManyFields');
        controller.uploadcsv();
        
        
        //Test negative case - Wrong data
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';        
        controller.recordtypeName = 'CN Stock In Request';
        //controller.fields = 'ASI_MFM_Lot_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        //controller.fieldsLabel = 'Lot Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        controller.fields = 'ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c';
        controller.fieldsLabel = 'Weight/Unit(KG),Case Size(M3)';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.upsertMode = false;
        controller.DefaultValues = 'Delivery Date(YYYYMMDD):2013-01-01';
        
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('Weight/Unit(KG),Case Size(M3)\r220,420');
        controller.uploadcsv();
        
        //Test negative case - File size exceed limit
        
        controller.filesize = 6242880;
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';        
        controller.recordtypeName = 'CN Stock In Request';
        controller.fields = 'ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c';
        controller.fieldsLabel = 'Weight/Unit(KG),Case Size(M3)';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.upsertMode = false;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('Weight/Unit(KG),Case Size(M3)\r220,420');
        controller.uploadcsv();
        
        controller.uploadCSVByBatch();
        controller.refreshPage();
        String[] statusMsgs = controller.StatusMsgs;
        
        
        controller.template2 = 'test';
        controller.report = 'test';
        controller.recEXID = 'test';
        controller.recEXIDcol = 'test';
        controller.parentObjectAPIName = 'test';
        controller.ParentObjectUploadMsg = 'test';
        controller.upsertMode = false;
        controller.batchMode = false;
        controller.opt_allOrNone = true;
        controller.monitorFieldName = 'ASI_MFM_Net_Weight__c';
        controller.objName = 'ASI_MFM_Stock_In_Request__c';
        controller.parentID = '123';
        controller.currentPageURLOutput = 'test';
        controller.LOutputRow = new List<ASI_MFM_CN_POSM_MassUploadByBatchCls.Row>();
        controller.AttId = null;
        
        Schema.SObjectType ObjType = Schema.getGlobalDescribe().get('ASI_MFM_PO_POSM_Line__c');
        ASI_MFM_CN_POSM_MassUploadByBatchCls.Row row = new ASI_MFM_CN_POSM_MassUploadByBatchCls.Row(ObjType.newSObject(), 'ASI_MFM_PO__c', po.id+'');
        
        
        test.stopTest();
    }
    
    public testMethod static void testUploadBatch(){
        ASI_MFM_Budget__c a = ASI_MFM_CAP_TestClassHelper.createBudget();      
        
        List<ASI_MFM_Prefix__c> pList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px1);
		ASI_MFM_Prefix__c px2= new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px2);
        insert pList; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
		List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr1);
		ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr2);
        insert prList;
        
		ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=px2.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
				ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=userInfo.getUserId(),ASI_MFM_Status__c='Final');
		insert plan;
			
		ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Plan__c = plan.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO'), name='test', ASI_MFM_PO_End_Date__c=Date.today(), ASI_MFM_PO_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft', ASI_MFM_Prefix__c=px1.id);
		insert po;
        
        
        ASI_MFM_PO_POSM_Line__c posmLine = new ASI_MFM_PO_POSM_Line__c(ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10);
        insert posmLine;
        
        test.startTest();
        
        String ObjAPIName ='ASI_MFM_Stock_In_Request__c';
        String parentID =po.id+'';
        String parentField ='ASI_MFM_PO_Number__c';
        String fields ='ASI_MFM_PO_POSM_Line_Number__c,ASI_MFM_Lot_Number__c,ASI_MFM_PO_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        String fieldsLabel ='PO POSM Line Number,Lot Number,PO Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        String lookupEXID ='ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        String template ='';
        String template2 ='';
        String report='';
        String recordtypeName ='CN Stock In Request';
        String currentPageURL =''; // v
        Boolean inlineVF =true;
        Boolean reloadNeeded =true;
        String defaultValues ='';
        String recEXID ='External ID';
        String recEXIDcol =''; 
        String parentObjectAPIName ='ASI_MFM_Mass_Upload_Log__c';
        String ParentObjectUploadMsg ='ASI_MFM_Error_Message__c';
        Boolean upsertMode =false;
        Boolean batchMode =false;
        Boolean opt_allOrNone=true;    
        Boolean emailNotification =true;
        String monitorFieldName ='ASI_MFM_PO_Number__c';
        Blob contentFile = blob.valueOf('Weight/Unit(KG),Case Size(M3)\r220,420');
        ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
        insert uploadLog;
        currentPageURL = uploadLog.id;
        
		fields = 'ASI_MFM_PO_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Length__c,ASI_MFM_SIR_Sent__c,ASI_Delivery_Date__c,ASI_MFM_Width__c,ASI_MFM_Qty_Per_Box__c';
        fieldsLabel = 'PO Number,Weight/Unit(KG),Case Size(M3),Length,Sent,Date,Width,QtyBox';
        lookupEXID ='ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        monitorFieldName ='ASI_MFM_PO_Number__c';
        contentFile = blob.valueOf('PO Number,Weight/Unit(KG),Case Size(M3),Length,Sent,Date,Width,QtyBox\rtest,220,420,1,y,20181010,1.11,10\rtest,220,420,1,y,2017-01-22,1.11,10');
        
        //AM@Introv 20190604 start
        lookupEXID = 'ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name,POSM RecordType&RecordTypeid;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name,PO RecordType&RecordTypeid';
        defaultValues = 'POSM RecordType:CN PO POSM Line;PO RecordType:CN PO,CN PO Read-Only';
        //AM@Introv 20190604 end
        
        Attachment att = new Attachment(ParentId = uploadLog.id, name = 'namefile.csv', body=contentFile, ContentType ='text/plain;charset=UTF-8');
        insert att;
        ASI_MFM_CN_POSM_MassUploadProcess batchProcess = new ASI_MFM_CN_POSM_MassUploadProcess(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                                                                                               defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                                                                                               upsertMode, emailNotification, opt_allOrNone, 'ASI_MFM_Timestamp__c');
        
		Id batchInstanceId = Database.executeBatch(batchProcess);
        List<attachment> attachList = [select id, name, body, description, parentid,owner.email from attachment where id =:att.id];
        batchProcess.execute(null, attachList);
        
        fields = 'ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c';
        fieldsLabel = 'Weight/Unit(KG),Case Size(M3)';
        contentFile = blob.valueOf('Weight/Unit(KG),Case Size(M3)\r220,"420"');
        defaultValues = 'Delivery Date(YYYYMMDD):2013-01-01';
        
        ASI_MFM_CN_POSM_MassUploadProcess batchProcess2 = new ASI_MFM_CN_POSM_MassUploadProcess(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                                                                                               defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                                                                                               upsertMode, emailNotification, opt_allOrNone, 'ASI_MFM_Timestamp__c');
        
		Id batchInstanceId2 = Database.executeBatch(batchProcess2);
        List<attachment> attachList2 = [select id, name, body, description, parentid,owner.email from attachment where id =:att.id];
        batchProcess.execute(null, attachList2);
        
        List<ASI_MFM_PO_POSM_Line__c> posmLineList = [select name from ASI_MFM_PO_POSM_Line__c where id =:posmline.id];
        String posmlineName = '';
        if(posmLineList.size()>0) posmlineName = posmLineList[0].name;
        fields ='ASI_MFM_PO_POSM_Line_Number__c,ASI_MFM_PO_Number__c,ASI_Delivery_Date__c';
        fieldsLabel ='PO POSM Line Number,PO Number,Delivery Date(YYYYMMDD)';
        lookupEXID ='ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        contentFile = blob.valueOf('PO POSM Line Number,PO Number,Delivery Date(YYYYMMDD)\r'+posmlineName+',test,20180101');
        defaultValues = 'Delivery Date(YYYYMMDD):2013-01-01';
        
        ASI_MFM_CN_POSM_MassUploadProcess batchProcess3 = new ASI_MFM_CN_POSM_MassUploadProcess(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                                                                                               defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                                                                                               upsertMode, emailNotification, opt_allOrNone, 'ASI_MFM_Timestamp__c');
        
		Database.executeBatch(batchProcess3);
        List<attachment> attachList3 = [select id, name, body, description, parentid,owner.email from attachment where id =:att.id];
        batchProcess.execute(null, attachList3);
        
        batchProcess.currentPageURLOutput = '';
        boolean bMode = batchProcess.batchMode;
        
        test.stopTest();
    }

}