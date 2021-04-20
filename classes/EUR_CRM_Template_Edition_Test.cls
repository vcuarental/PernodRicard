@isTest
public with sharing class EUR_CRM_Template_Edition_Test {
    @isTest static void testTemplateCriteria() {
        EUR_CRM_JB_Template__c tpl = [SELECT Id FROM EUR_CRM_JB_Template__c WHERE EUR_JB_External_Id__c = 'KE_Leading_RST'];
        EUR_CRM_JB_Template__c tpl2 = [SELECT Id FROM EUR_CRM_JB_Template__c WHERE EUR_JB_External_Id__c = 'KE_Premium_RST'];
        
        EUR_CRM_Template_Criteria_Edition.getTemplates(tpl.Id);

        EUR_CRM_Template_Criteria_Edition.Data data = EUR_CRM_Template_Criteria_Edition.loadData(tpl.Id, null);

        EUR_CRM_Template_Criteria_Edition.Criteria icriteria = data.criterias[0];
        
        List<EUR_CRM_Template_Criteria_Edition.Criteria> liste = new List<EUR_CRM_Template_Criteria_Edition.Criteria>();
        liste.add(icriteria);
        EUR_CRM_Template_Criteria_Edition.saveTemplateCriterias(JSON.serialize(liste), tpl2.Id);
        
        System.assertEquals(tpl2.Id, [SELECT EUR_JB_Template__c FROM EUR_CRM_JB_Template_Criteria__c].EUR_JB_Template__c, 'Wrong template associated with criteria');
    }

    @isTest static void testOnTrade() {
        EUR_CRM_JB_Template__c tpl = [SELECT Id FROM EUR_CRM_JB_Template__c WHERE EUR_JB_External_Id__c = 'KE_Leading_RST'];
        try {
            EUR_CRM_Template_Edition.checkRequiredMetadata(tpl.id);
        } catch(Exception e) {
            System.assert(false);
        }
        
        
        List<EUR_CRM_Template_Edition.TemplateLine> linesTpl = EUR_CRM_Template_Edition.getTemplateLines(tpl.id);
        System.assertEquals(1, linesTpl.size());
        System.assertEquals('Chivas Regal 12YO', linesTpl[0].product);
        List<EUR_CRM_Template_Edition.TemplateLine> linesProduct = EUR_CRM_Template_Edition.getProducts(tpl.id);
        System.assertEquals(1, linesProduct.size());
        System.assertEquals('Chivas Regal 18YO', linesProduct[0].product);

        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'required');
        System.assertEquals('R', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'recommanded');
        System.assertEquals('Recommanded', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'contracted');
        System.assertEquals('Contracted', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'optional');
        System.assertEquals('O', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        
        EUR_CRM_Template_Edition.addToTemplate(linesProduct[0]);
        System.assertEquals(2, [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].size());
        EUR_CRM_Template_Edition.deleteTemplateLine(linesTpl[0]);
        System.assertEquals(1, [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].size());
        
        EUR_CRM_Template_Edition.cloneTemplateAndLines(tpl.id);
        System.assertEquals(2, [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE RecordType.Name LIKE 'EUR KE On%'].size(), 'Wrong number of template lines');
        //Indeed I create another template to make a test on the template criteria, that's why we have 3
        System.assertEquals(3, [SELECT Id FROM EUR_CRM_JB_Template__c WHERE RecordType.Name LIKE 'EUR KE On%'].size(), 'Wrong number of templates');
        
    }

    @isTest static void testOffTrade() {
        EUR_CRM_JB_Template__c tpl = [SELECT Id FROM EUR_CRM_JB_Template__c WHERE EUR_JB_External_Id__c = 'KE_Non_Conventional'];
        try {
            EUR_CRM_Template_Edition.checkRequiredMetadata(tpl.id);
        } catch(Exception e) {
            System.assert(false);
        }
        
        
        List<EUR_CRM_Template_Edition.TemplateLine> linesTpl = EUR_CRM_Template_Edition.getTemplateLines(tpl.id);
        System.assertEquals(1, linesTpl.size());
        System.assertEquals('Chivas Regal 12YO 5cl', linesTpl[0].product);
        List<EUR_CRM_Template_Edition.TemplateLine> linesProduct = EUR_CRM_Template_Edition.getProducts(tpl.id);
        System.assertEquals(1, linesProduct.size());
        System.assertEquals('Chivas Regal 18YO 5cl', linesProduct[0].product);

        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'required');
        System.assertEquals('R', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'recommanded');
        System.assertEquals('Recommanded', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'contracted');
        System.assertEquals('Contracted', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        EUR_CRM_Template_Edition.changeLineStatus(linesTpl[0], 'optional');
        System.assertEquals('O', [SELECT EUR_JB_Listing__c FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].EUR_JB_Listing__c);
        
        EUR_CRM_Template_Edition.addToTemplate(linesProduct[0]);
        System.assertEquals(2, [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].size());
        EUR_CRM_Template_Edition.deleteTemplateLine(linesTpl[0]);
        System.assertEquals(1, [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE EUR_JB_CRM_Template__c = :tpl.Id].size());
        
        EUR_CRM_Template_Edition.cloneTemplateAndLines(tpl.id);
        System.assertEquals(2, [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE RecordType.Name LIKE 'EUR KE Off%'].size(), 'Wrong number of template lines');
        System.assertEquals(2, [SELECT Id FROM EUR_CRM_JB_Template__c WHERE RecordType.Name LIKE 'EUR KE Off%'].size(), 'Wrong number of templates');
        
        
    }

    @testSetup static void loadData() {
        
        EUR_CRM_Wine_Spirits__c wine = new EUR_CRM_Wine_Spirits__c();
        wine.Name = 'SPIRIT';
        wine.RecordTypeId = Schema.SObjectType.EUR_CRM_Wine_Spirits__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Wine_Spirits').getRecordTypeId();
        insert wine;

        EUR_CRM_Category__c categ = new EUR_CRM_Category__c();
        categ.Name = 'WHISKY';
        categ.EUR_CRM_Wine_Spirits__c = wine.id;
        categ.RecordTypeId = Schema.SObjectType.EUR_CRM_Category__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Category').getRecordTypeId();
        insert categ;

        EUR_CRM_Brand__c b = new EUR_CRM_Brand__c();
        b.Name = 'CHIVAS';
        b.EUR_CRM_Active__c = true;
        b.EUR_CRM_Category__c = categ.Id;
        b.RecordTypeId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Brand').getRecordTypeId();
        insert b;

        EUR_CRM_Quality__c bq = new EUR_CRM_Quality__c();
        bq.Name = 'Chivas Regal 12YO';
        bq.EUR_CRM_Active__c = true;
        bq.EUR_CRM_Brand__c = b.id;
        bq.RecordTypeId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Quality').getRecordTypeId();
        insert bq;
        EUR_CRM_Quality__c bq2 = new EUR_CRM_Quality__c();
        bq2.Name = 'Chivas Regal 18YO';
        bq2.EUR_CRM_Active__c = true;
        bq2.EUR_CRM_Brand__c = b.id;
        bq2.RecordTypeId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Quality').getRecordTypeId();
        insert bq2;
        
        EUR_CRM_Size__c bqs = new EUR_CRM_Size__c();
        bqs.Name = 'Chivas Regal 12YO 5cl';
        bqs.EUR_CRM_Active__c = true;
        bqs.EUR_CRM_Brand_Quality__c = bq.Id;
        bqs.RecordTypeId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Size').getRecordTypeId();
        insert bqs;
        EUR_CRM_Size__c bqs2 = new EUR_CRM_Size__c();
        bqs2.Name = 'Chivas Regal 18YO 5cl';
        bqs2.EUR_CRM_Active__c = true;
        bqs2.EUR_CRM_Brand_Quality__c = bq2.Id;
        bqs2.RecordTypeId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Size').getRecordTypeId();
        insert bqs2;

        EUR_CRM_JB_Template__c tplOn = new EUR_CRM_JB_Template__c(
            Name = 'KE Template for Leading Restaurant',
            EUR_JB_External_Id__c = 'KE_Leading_RST',
            RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_On_Trade_Template').getRecordTypeId()
        );

        insert tplOn;
        EUR_CRM_JB_Template__c tplOn2 = new EUR_CRM_JB_Template__c(
            Name = 'KE Template for Premium Restaurant',
            EUR_JB_External_Id__c = 'KE_Premium_RST',
            RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_On_Trade_Template').getRecordTypeId()
        );
        
        insert tplOn2;
        EUR_CRM_JB_Template__c tplOff = new EUR_CRM_JB_Template__c(
            Name = 'KE Template for Non conventional',
            EUR_JB_External_Id__c = 'KE_Non_Conventional',
            RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Off_Trade_Template').getRecordTypeId()
        );
        insert tplOff;

        EUR_CRM_JB_Template_Line__c l1 = new EUR_CRM_JB_Template_Line__c(
            EUR_JB_CRM_Template__c = tplOn.id,
            EUR_Brand_Quality_Size__c = null,
            EUR_JB_Brand_Quality__c = bq.Id,
            RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template_Line__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_On_Trade_Template_Line').getRecordTypeId()
        );
        EUR_CRM_JB_Template_Line__c l2 = new EUR_CRM_JB_Template_Line__c(
            EUR_JB_CRM_Template__c = tplOff.id,
            EUR_Brand_Quality_Size__c = bqs.Id,
            EUR_JB_Brand_Quality__c = null,
            RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template_Line__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Off_Trade_Template_Line').getRecordTypeId()
        );
        insert l1;
        insert l2;


        EUR_CRM_PRS_Group_Outlet_Type__c got1 = new EUR_CRM_PRS_Group_Outlet_Type__c(
            EUR_CRM_Group_Outlet_Type_Name__c = 'Restaurant',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_On_Trade_Group_Outlet_Type').getRecordTypeId()  
        );
        EUR_CRM_PRS_Group_Outlet_Type__c got2 = new EUR_CRM_PRS_Group_Outlet_Type__c(
            EUR_CRM_Group_Outlet_Type_Name__c = 'Night Club',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_On_Trade_Group_Outlet_Type').getRecordTypeId()  
        );

        insert got1; insert got2;

        EUR_CRM_PRS_Outlet_Type__c ot1 = new EUR_CRM_PRS_Outlet_Type__c(
            EUR_CRM_PRS_Outlet_Type_Name__c = 'French Restaurant',
            EUR_CRM_PRS_Group_Outlet_Type__c = got1.Id,
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_On_Trade_Outlet_Type').getRecordTypeId()
        );
        EUR_CRM_PRS_Outlet_Type__c ot2 = new EUR_CRM_PRS_Outlet_Type__c(
            EUR_CRM_PRS_Outlet_Type_Name__c = 'Italian Restaurant',
            EUR_CRM_PRS_Group_Outlet_Type__c = got2.Id,
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_On_Trade_Outlet_Type').getRecordTypeId()
        );
        insert ot1; insert ot2;

        EUR_CRM_PRS_Seg_Aspect__c il1 = new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_Segmentation_Aspect_Image_Level').getRecordTypeId()
        );
        EUR_CRM_PRS_Seg_Aspect__c il2 = new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Premium',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_Segmentation_Aspect_Image_Level').getRecordTypeId()
        );
        EUR_CRM_PRS_Seg_Aspect__c il3 = new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Leading',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_Segmentation_Aspect_Image_Level').getRecordTypeId()
        );
        insert il1; insert il2; insert il3;

        EUR_CRM_PRS_Seg_Aspect__c vp1 = new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_Segmentation_Aspect_Volume_Potential').getRecordTypeId()
        );
        EUR_CRM_PRS_Seg_Aspect__c vp2 = new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Medium',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_Segmentation_Aspect_Volume_Potential').getRecordTypeId()
        );
        EUR_CRM_PRS_Seg_Aspect__c vp3 = new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_PRS_Segmentation_Aspect_Volume_Potential').getRecordTypeId()
        );
        insert vp1; insert vp2; insert vp3;

        EUR_CRM_JB_Template_Criteria__c cri1 = new EUR_CRM_JB_Template_Criteria__c(
            EUR_CRM_PRS_Seg_Aspect_IL__c = il1.Id,
            EUR_CRM_PRS_Seg_Aspect_VP__c = vp1.Id,
            EUR_CRM_PRS_Group_Outlet_Type__c = got1.Id,
            EUR_CRM_PRS_Outlet_Type__c = ot1.Id,
            EUR_JB_Template__c = tplOn.Id
        );
        insert cri1;
    }
}