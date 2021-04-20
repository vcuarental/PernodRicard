@isTest(SeeAllData=false)
public class ASI_CRM_TW_MassEditTestClass {

    static testMethod void ASI_CRM_TW_InputFOCItemsPagingController_Test(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name = 'testSubBrand',
            ASI_CRM_TW_Company__c = 'PRT', 
            ASI_CRM_Active__c = TRUE, 
            ASI_TH_CRM_Active__c = TRUE,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
        );
        insert sub;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
            Name = 'TOT (酒店)',
            ASI_CRM_CN_Channel_Code__c = 'TOT');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
            Name = 'Piano Bar (PB)', 
            ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
            ASI_CRM_CN_Channel__c = channel.id, 
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
        insert subChannel;   
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
            Name = 'PB (鋼琴酒吧)', 
            ASI_TH_CRM_Code__c = 'TW_PB',
            ASI_CRM_Sub_Channel__c = subChannel.id
        );
        insert outletType;
            
        List<Account> listAcc = new List<Account>();
        listAcc.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
            Name='Test Outlet', 
            ASI_TH_CRM_Region__c ='North',
            ASI_KOR_Customer_Code__c = 'EXID_123')
        );   
        insert listAcc;
        
        List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
        listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
            Name = 'Test Outlet', 
            ASI_CRM_Account__c = listAcc[0].id, 
            ASI_TH_CRM_OutletType__c = outletType.id, 
            ASI_CRM_Region__c = 'North',
            ASI_CRM_Channel__c = channel.id,
            ASI_CRM_CN_Sub_Channel__c = subChannel.id,
            ASI_CRM_City__c = 'Test City', 
            ASI_CRM_Town__c = 'Test Town', 
            ASI_CRM_TW_Street__c = 'Test Street', 
            ASI_CRM_TW_Number__c = '1', 
            ASI_CRM_TW_Floor__c = '12')
        );
        insert listAccountAdditionalField;
        
        List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
        listSKU.add(new ASI_MFM_SKU_Code__c(
            name = 'POSM SKU',
            ASI_HK_CRM_Active__c = TRUE,
            ASI_MFM_Sub_brand__c = sub.id,
            //ASI_MFM_Item_Group__c = listItemGp[0].id,
            ASI_HK_CRM_IsPOSProduct__c = TRUE,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
        );
        insert listSKU;
            
        
        List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
        //POSM
        listFGR.add(new ASI_FOC_Free_Goods_Request__c(
            recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
            ASI_CRM_Target_Outlet__c = listAcc[0].Id,
            ASI_CRM_Receiver__c = 'Mary',
            ASI_CRM_SG_Order_Date__c = date.today(),
            ASI_CRM_Purpose__c = 'purpose')
        );
        insert listFGR;
        
        List<ASI_FOC_Request_Item__c> listItems = new List<ASI_FOC_Request_Item__c>();
        //POSM
        listItems.add(new ASI_FOC_Request_Item__c(
            recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_POSM_Request_Item'),
            ASI_FOC_Request_Order__c = listFGR[0].Id,
            ASI_FOC_SKU__c = listSKU[0].id,
            ASI_FOC_Request_Quantity_Bottle__c = 10)
        );
        insert listItems;
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listFGR[0]);
        ApexPages.currentPage().getParameters().put('id', listFGR[0].id);  

        ASI_CRM_TW_FOCRequestPDF_Ctrl controller = new ASI_CRM_TW_FOCRequestPDF_Ctrl(stdController); 
        
        ASI_CRM_TW_InputFOCItemsPagingController  mcauCon = new ASI_CRM_TW_InputFOCItemsPagingController (stdController);
        
        // Assign component attributes
        //mcauCon.isFastModeBool = false;
        //mcauCon.sObjTypeStr = 'ASI_FOC_Request_Item__c';
        //mcauCon.displayFieldsStr = 'ASI_FOC_SKU__c&req=T&width=250px,ASI_FOC_Request_Quantity_Bottle__c&req=T&width=100px,ASI_CRM_Target_Outlet__c&req=F&width=100px,ASI_CRM_Delivery_To__c&req=F&width=100px,ASI_CRM_Delivery_Address__c&req=F&width=150px,ASI_CRM_Delivery_Tel__c&req=F&width=100px,ASI_CRM_Receiver__c&req=F&width=100px,ASI_FOC_Remark__c&req=F&width=100px&,recordTypeId&width=100px';        
        //mcauCon.fieldToURLParamStr = 'ASI_FOC_Request_Order__c=>id';
        //mcauCon.whereStatm = 'ASI_FOC_Request_Order__c = \'' + listFGR[0].Id + '\'';
        //mcauCon.pageBlockTitleStr = 'POSM Line Items';
        //mcauCon.successLink = '/' + listFGR[0].Id;
        //mcauCon.cancelLink = '/' + listFGR[0].Id;
        //mcauCon.mode = 'BOTH';
        //mcauCon.isDefaultEditVal = true;
        //mcauCon.ShowAllRT = true;
        //mcauCon.ComponentKey = 'massCreateAndUpdate';
        //mcauCon.lookupToPicklist = 'ASI_FOC_SKU__c';

        Test.startTest();
        mcauCon.Beginning();
        mcauCon.searchSubBrandId = sub.Id;
        mcauCon.Next();
        mcauCon.Previous();
        mcauCon.search();
        mcauCon.getItemRecordTypes();
        mcauCon.getSubBrandlist();
        mcauCon.getAccountCodelist();
        mcauCon.getCustomerNamelist();
        mcauCon.getSKUlist();
        mcauCon.getDeliverTolist();
        mcauCon.getOutletlist();
        mcauCon.quickSave();
        // mcauCon.save();
        mcauCon.DELETESELECTED();
        mcauCon.ADDNEW();
        mcauCon.CLONESELECTED();
        mcauCon.cacnel();
        mcauCon.APPLY();
        try{
            mcauCon.onCommitted();
        }catch(Exception ex){}
        mcauCon.QueryReceiver();
        mcauCon.results[0].seqNO = 0;
        mcauCon.CurrentSeqNO = 0;
        mcauCon.results[0].ppl.ASI_CRM_Delivery_To__c = listAcc[0].id;
        mcauCon.ADDNEW();
        mcauCon.QueryReceiver();
        mcauCon.onchangeDeliveryTo();
        mcauCon.End();
        mcauCon.reset();
        mcauCon.getDisablePrevious();
        mcauCon.searchMainContact();
        mcauCon.searchCurrentPage();
        mcauCon.results[0].ppl.ASI_CRM_Delivery_To__c = null;
        mcauCon.QueryReceiver();
        mcauCon.onchangeDeliveryTo();
        mcauCon.results[0].selected = false;
        mcauCon.DELETESELECTED();
        Test.stopTest();
    }

    public class HTTPMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            string jsonResBody = '{"results":[{"address_components":[{"long_name":"Muir Lane","short_name":"Muir Ln","types":["route"]},{"long_name":"Torrey Pines","short_name":"Torrey Pines","types":["neighborhood","political"]},{"long_name":"San Diego","short_name":"San Diego","types":["locality","political"]},{"long_name":"San Diego County","short_name":"San Diego County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"92161","short_name":"92161","types":["postal_code"]}],"formatted_address":"Muir Ln, San Diego, CA 92161, USA","geometry":{"location":{"lat":32.8790299,"lng":-117.2413533},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":32.8803788802915,"lng":-117.2400043197085},"southwest":{"lat":32.8776809197085,"lng":-117.2427022802915}}},"place_id":"ChIJV1aG1sAG3IAR6EsgRezpoa0","plus_code":{"compound_code":"VQH5+JF San Diego, California, United States","global_code":"8544VQH5+JF"},"types":["establishment","point_of_interest","school"]}],"status":"OK"}';
            res.setBody(jsonResBody);
            return res;
        }
    }
}