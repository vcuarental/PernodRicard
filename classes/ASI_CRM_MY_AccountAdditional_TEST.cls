@isTest
/****************************************
Test Classes:
1. ASI_CRM_MY_AccountAdditional_TriggerCls
****************************************/
public class ASI_CRM_MY_AccountAdditional_TEST{
    
    private final static String question = 'Sample question 1?';
    
    @testSetup static void setup() {
        // Create common test accounts
             

        
    }

   
    static testMethod void ASI_CRM_MY_AccountAdditional_TriggerCls_TEST() {
        
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        //Group testGroup = new Group();
        //testGroup.Name = 'ASI_CRM_MY_Contract_Final';
        //testGroup.DeveloperName = 'ASI_CRM_MY_Contract_Final';
        //INSERT testGroup;
        
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Contract_Final' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
      
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_City__c city2 = ASI_CRM_MY_TestClassHelper.createCity('Branch2', 'Region2');
            
            //ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            //ASI_CRM_AccountsAdditionalField__c customer2 = ASI_CRM_MY_TestClassHelper.createCustomer('customer2', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_DummyOutletColdCall');
            //ASI_CRM_AccountsAdditionalField__c customer3 = ASI_CRM_MY_TestClassHelper.createCustomer('customer3', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_DummyOutletDepletion');
            
            // 10/05/2018
            ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_MY_TestClassHelper.createCustomer('customer4', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
            customer.ASI_CRM_MY_City__c = city2.id;
            customer.ownerId = userA.id;
            update customer;
            
            set<Id> criteriaSet = new set<Id>();
            
            ASI_CRM_Criteria_Set__c criteria_image_set = new ASI_CRM_Criteria_Set__c();
            criteria_image_set.ASI_CRM_SG_Name__c = 'Asian Restaurant';
            criteria_image_set.Region__c = 'Central';
            criteria_image_set.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Set__cMY_Image_Level_Criteria');
            insert criteria_image_set;
            criteriaSet.add(criteria_image_set.Id);
            
            
            ASI_CRM_Criteria_Set__c criteria_volume_set = new ASI_CRM_Criteria_Set__c();
            criteria_volume_set.ASI_CRM_SG_Name__c = 'Volume Criteria - Asian Restaurant';
            criteria_volume_set.Region__c = 'Central';
            criteria_volume_set.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Set__cASI_MY_Volume_Potential_Criteria');
            insert criteria_volume_set;    
            criteriaSet.add(criteria_volume_set.Id);
            
            
            ASI_CRM_Group_Outlet_Type__c group_outlet = new ASI_CRM_Group_Outlet_Type__c();
            group_outlet.ASI_CRM_SG_Group_Outlet_Name__c = 'Asian Restaurant';
            group_outlet.ASI_CRM_SG_Image_Criteria_Set__c  = criteria_image_set.id;
            group_outlet.ASI_CRM_SG_Volume_Criteria_Set__c = criteria_volume_set.id;
            group_outlet.ASI_CRM_MY_Channel_Code__c = 'asian_restaurant';
            group_outlet.ASI_CRM_Region__c = 'Central';
            group_outlet.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Group_Outlet_Type__cASI_CRM_MY_Group_Outlet_Type');
            insert group_outlet;
            
            
            ASI_CRM_Outlet_Type__c outlet_type = new ASI_CRM_Outlet_Type__c();
            outlet_type.ASI_CRM_SG_Group_Outlet_Type__c = group_outlet.id;
            outlet_type.ASI_CRM_SG_Name__c = 'Chinese Restaurant';
            outlet_type.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Outlet_Type__cASI_CRM_MY_Outlet_Type');
            insert outlet_type;
            
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c();
            channel.Name = 'Asian Restaurant';
            channel.ASI_CRM_CN_Channel_Code__c = 'asian_restaurant';
            channel.ASI_CRM_CN_On_Off__c = 'On';
            channel.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel__cASI_CRM_MY_Segmentation_Channel');
            insert channel;
                
            
            ASI_MFM_Sub_Channel__c sub_channel = new ASI_MFM_Sub_Channel__c();
            sub_channel.Name = 'Chinese Restaurant';
            sub_channel.ASI_CRM_CN_Channel__c = channel.id;
            sub_channel.ASI_CRM_CN_Eng_Name__c = 'Chinese Restaurant';
            sub_channel.ASI_CRM_MY_Outlet_Type__c = outlet_type.id;
            insert sub_channel;
            
            /*
            ASI_CRM_Pros_Segmentation__c pros = new ASI_CRM_Pros_Segmentation__c();
            pros.ASI_CRM_SG_Customer__c = customer.id;
            pros.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_MY_PROS_Segmentation');
            insert pros;
            */    
            
            // CUSTOMER PAGE
            ApexPages.StandardController standardCtl = new ApexPages.StandardController(customer);
            ApexPages.currentpage().getparameters().put('id', customer.id);
            ASI_CRM_MY_AccountProsSegController controller_customer = new ASI_CRM_MY_AccountProsSegController(standardCtl);
            controller_customer.createProsSegmentation();
            controller_customer.getCustomLink();
           
            
            ASI_CRM_Pros_Segmentation__c pros = [SELECT id FROM ASI_CRM_Pros_Segmentation__c LIMIT 1];
            
            
            ASI_CRM_Criteria_Threshold__c criteriaThreshold = new ASI_CRM_Criteria_Threshold__c();
            criteriaThreshold.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_SG_Integer_Input');
            criteriaThreshold.ASI_CRM_SG_Criteria_Set__c = criteria_image_set.id;
            criteriaThreshold.ASI_CRM_SG_Question__c = question;
            criteriaThreshold.ASI_CRM_SG_Weight__c = 100;
            insert criteriaThreshold;
            
            
            ASI_CRM_Criteria_Threshold__c criteriaVolumeThreshold = new ASI_CRM_Criteria_Threshold__c();
            criteriaVolumeThreshold.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_SG_Integer_Input');
            criteriaVolumeThreshold.ASI_CRM_SG_Criteria_Set__c = criteria_volume_set.id;
            criteriaVolumeThreshold.ASI_CRM_SG_Question__c = 'Potential Volume';
            criteriaVolumeThreshold.ASI_CRM_SG_Weight__c = 100;
            insert criteriaVolumeThreshold;
            
            
            ASI_CRM_Criteria_Answer__c criteriaAnswer = new ASI_CRM_Criteria_Answer__c();
            criteriaAnswer.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_SG_Integer_Input');
            criteriaAnswer.ASI_CRM_SG_Base_Currency__c = null;
            criteriaAnswer.ASI_CRM_SG_Base_Integer__c = Integer.valueOf(0);
            criteriaAnswer.ASI_CRM_SG_Condition__c = 'Greater Than (>)';
            criteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = criteriaThreshold.id;
            criteriaAnswer.ASI_CRM_SG_Weight__c = 100;
            insert criteriaAnswer;
            
            
            ASI_CRM_Criteria_Answer__c criteriaVolumeAnswer = new ASI_CRM_Criteria_Answer__c();
            criteriaVolumeAnswer.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_SG_Integer_Input');
            criteriaVolumeAnswer.ASI_CRM_SG_Base_Integer__c = Integer.valueOf(0);
            criteriaVolumeAnswer.ASI_CRM_SG_Condition__c = 'Greater Than or Equal (>=)';
            criteriaVolumeAnswer.ASI_CRM_SG_Criteria_Threshold__c = criteriaVolumeThreshold.id;
            criteriaVolumeAnswer.ASI_CRM_SG_Weight__c = 100;
            insert criteriaVolumeAnswer;
            
            
            ASI_CRM_Pros_Image_Level__c pro_image_level = new ASI_CRM_Pros_Image_Level__c();
            pro_image_level.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Image_Level__cASI_CRM_MY_Pros_Image_Level');
            pro_image_level.ASI_CRM_SG_Answer__c = '50';
            pro_image_level.ASI_CRM_SG_Criteria_Threshold__c = criteriaThreshold.id;
            pro_image_level.ASI_CRM_SG_Weight__c = 15;
            pro_image_level.ASI_CRM_SG_Pros_Segmentation__c = pros.id;
            insert pro_image_level;
            
            ASI_CRM_Pros_Volume_Potential__c pro_volume_level = new ASI_CRM_Pros_Volume_Potential__c();
            pro_volume_level.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Volume_Potential__cASI_CRM_MY_Pros_Volume_Potential');
            pro_volume_level.ASI_CRM_SG_Answer__c = '1223345';
            pro_volume_level.ASI_CRM_SG_Criteria_Threshold__c = criteriaVolumeThreshold.id;
            pro_volume_level.ASI_CRM_SG_Weight__c = 1223346;
            pro_volume_level.ASI_CRM_SG_Pros_Segmentation__c = pros.id;
            insert pro_volume_level;
            
            
            ASI_CRM_Image_Level__c image_level = new ASI_CRM_Image_Level__c();
            image_level.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Image_Level__cASI_CRM_MY_Image_Level');
            image_level.ASI_CRM_SG_Name__c = 'iconic';
            image_level.ASI_CRM_SG_Min_Weight__c = 90;
            insert image_level;
            
            
            ASI_CRM_Volume_Potential__c volume_level = new ASI_CRM_Volume_Potential__c();
            volume_level.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Volume_Potential__cASI_CRM_MY_Volume_Potential');
            volume_level.ASI_CRM_SG_Min_Weight__c = 0;
            insert volume_level;
            
            
            ASI_CRM_Image_Level_Threshold__c image_level_threshold = new ASI_CRM_Image_Level_Threshold__c();
            image_level_threshold.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Image_Level_Threshold__cASI_CRM_MY_Image_Level_Threshold'); 
            image_level_threshold.ASI_CRM_SG_Min_Weight__c = 50;
            image_level_threshold.ASI_CRM_SG_Image_Level__c = image_level.id;
            image_level_threshold.ASI_CRM_SG_Group_Outlet_Type__c = group_outlet.id;
            insert image_level_threshold;
            
            
            ASI_CRM_Volume_Potential_Threshold__c volume_level_threshold = new ASI_CRM_Volume_Potential_Threshold__c();
            volume_level_threshold.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Volume_Potential_Threshold__cASI_CRM_MY_Gross_Sale'); 
            volume_level_threshold.ASI_CRM_SG_Min_Weight__c  = 0;
            volume_level_threshold.ASI_CRM_SG_Group_Outlet_Type__c = group_outlet.id;
            volume_level_threshold.ASI_CRM_SG_Volume_Potential__c = volume_level.id;
            volume_level_threshold.ASI_CRM_Region__c = 'Central';
            insert volume_level_threshold;
            
            
            ASI_CRM_PROS_OutletPrioritization__c pros_outlet_prioritization = new ASI_CRM_PROS_OutletPrioritization__c();
            pros_outlet_prioritization.Name = 'Brand builder';
            insert pros_outlet_prioritization;
            
           
            
            ASI_CRM_PROS_OutPriCon__c pros_outpricon = new ASI_CRM_PROS_OutPriCon__c();
            pros_outpricon.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PROS_OutPriCon__cASI_CRM_MY_Outlet_Prioritization'); 
            pros_outpricon.Name = 'Brand builder';
            pros_outpricon.ASI_CRM_Image_Level__c  = image_level.id;
            pros_outpricon.ASI_CRM_Outlet_Type__c  = outlet_type.id;
            pros_outpricon.ASI_CRM_MY_Outlet_Prioritization__c  = pros_outlet_prioritization.id;
            insert pros_outpricon;
            
            
            //pros.ASI_CRM_SG_Customer__c = customer4.id;
            pros.ASI_CRM_SG_Group_Outlet_Type__c = group_outlet.id;
            pros.ASI_CRM_SG_Outlet_Type__c = outlet_type.Id;
            pros.Channel__c = channel.id;
            pros.Sub_Channel__c = sub_channel.id;
            pros.Region__c = 'Central';
            pros.Contracted_Brand__c = 'PRM';
            update pros;
            
                    
            ASI_HK_CRM_Product_Category__c product_category = new ASI_HK_CRM_Product_Category__c();
            product_category.Name = 'Champagne';
            product_category.ASI_HK_CRM_Category_Code__c = 'CH';
            product_category.ASI_HK_CRM_English_Name__c = 'ASI_HK_CRM_English_Name__c';
            product_category.recordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_MY_CRM_Product_Category');
            insert product_category;
            
            
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c();
            brand.Name = 'MUMM CHAMPAGNE-MUM';
            brand.ASI_HK_CRM_Product_Category__c = product_category.Id;
            brand.ASI_TH_CRM_Active__c = true;
            brand.ASI_MFM_Brand_Code__c  = 'MUM';
            brand.ASI_MFM_Brand_Description__c  = 'MUMM CHAMPAGNE';
            brand.ASI_MFM_Brand_External_ID__c  = 'MY_MUM';
            brand.recordTypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Brand__cASI_MFM_MY_Brand');
            insert brand;
            
            
            ASI_MFM_Sub_brand__c sub_brand = new ASI_MFM_Sub_brand__c();
            sub_brand.Name = 'MUMM CORDON ROUGE-MUC';
            sub_brand.ASI_MFM_Brand__c = brand.Id;
            sub_brand.ASI_HK_CRM_Product_Category__c = product_category.Id;
            sub_brand.recordTypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand');
            insert sub_brand;
            
            
            ASI_CRM_ID_Card__c card = new ASI_CRM_ID_Card__c();
            card.ASI_CRM_SG_Outlet__c = customer.Id;
            card.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ID_Card__cASI_CRM_MY_ID_Card');
            insert card;
            
            
            ASI_CRM_Quality__c brand_quality = new ASI_CRM_Quality__c();
            brand_quality.Name = 'Mumm Cordon Rouge';
            brand_quality.ASI_CRM_SG_Brand__c  = brand.Id;
            brand_quality.ASI_CRM_MY_Sub_brand__c  = sub_brand.Id;
            brand_quality.ASI_CRM_MY_Price__c  = 2475;
            brand_quality.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Quality__cASI_CRM_MY_Brand_Quality');
            insert brand_quality;
            
            
            ASI_CRM_ID_Card_Volume__c card_volume = new ASI_CRM_ID_Card_Volume__c();
            card_volume.ASI_CRM_SG_Annual_Volume__c = 50;
            card_volume.ASI_CRM_SG_ID_Card__c = card.Id;
            card_volume.ASI_CRM_SG_Service_Mark__c = brand_quality.Id;
            card_volume.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ID_Card_Volume__cASI_CRM_MY_ID_Card_Volume');
            insert card_volume;
            
            
            ASI_CRM_DAMD_Threshold__c damd = new ASI_CRM_DAMD_Threshold__c();
            damd.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_DAMD_Threshold__cASI_CRM_MY_DAMD_GRADE');
            damd.ASI_CRM_SG_Group_Outlet_Type__c = group_outlet.id;
            damd.ASI_CRM_SG_Volume_Potential__c = volume_level.Id;
            damd.ASI_CRM_SG_Min_Weight__c = 0.4;
            damd.ASI_CRM_SG_Action__c = 'Attack';
            damd.ASI_CRM_SG_Market_Share__c = 'High';
            damd.ASI_CRM_MY_Outlet_Prioritization__c = pros_outlet_prioritization.id;
            damd.ASI_CRM_Visit_Duration__c = 75;
            insert damd;
            
            
            ASI_CRM_Visit_Frequency_Thresholds__c freqThreshold = new ASI_CRM_Visit_Frequency_Thresholds__c();
            freqThreshold.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Visit_Frequency_Thresholds__cASI_CRM_MY_Visit_Frequency_Thresholds');
            freqThreshold.ASI_CRM_Outlet_Prioritization__c = pros_outlet_prioritization.id;
            freqThreshold.ASI_CRM_Visit_Frequency__c = 4.0;
            freqThreshold.ASI_CRM_MY_Action_Coding__c = 'Attack NCO';
            insert freqThreshold;
            
            Test.startTest();
            ApexPages.StandardController standardCtl_pros2 = new ApexPages.StandardController(pros); 
            ApexPages.currentpage().getparameters().put('id', pros.id);
            ApexPages.currentpage().getparameters().put('type', '1');
            ASI_CRM_MY_CriteriaController criteria_image_controller = new ASI_CRM_MY_CriteriaController(standardCtl_pros2);
            criteria_image_controller.saveCriteriaSheet();
            criteria_image_controller.addRequiredMessage();
            ApexPages.currentpage().getparameters().put('id', pros.id);
            ApexPages.currentpage().getparameters().put('type', '2');
            ASI_CRM_MY_CriteriaController criteria_volume_controller = new ASI_CRM_MY_CriteriaController(standardCtl_pros2);
            List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds = new List<ASI_CRM_Volume_Potential_Threshold__c>();
            volumePotentialThresholds.add(volume_level_threshold);
            criteria_volume_controller.setVolumePotentialThresholds(volumePotentialThresholds);
            criteria_volume_controller.saveCriteriaSheet();
            criteria_volume_controller.cancel();
            
            
            //ASI_CRM_Pros_Segmentation__c pros = [SELECT id FROM ASI_CRM_Pros_Segmentation__c LIMIT 1];
            ApexPages.currentpage().getparameters().put('id', pros.id);
            ASI_CRM_MY_VolumeCardControllerExt volume_card_controller2 = new ASI_CRM_MY_VolumeCardControllerExt();
            ASI_CRM_Pros_Segmentation__c prosSegmentation = ASI_CRM_MY_ProsSegmentationClass.returnProsSegmentationviaId(pros.id);
            volume_card_controller2.prosSegmentationObj = prosSegmentation;
            volume_card_controller2.isVolumeCardAvailable = true;
            volume_card_controller2.isVolumeDisabled = false;
            //map<String, String> damdmatrixMap = new map<String, String>();
            //damdmatrixMap.put('test', 'test');
            //volume_card_controller2.damdmatrixMap = damdmatrixMap;
            volume_card_controller2.initVolCard();
            volume_card_controller2.criarIdCard();
            volume_card_controller2.templiVolWrapper.sort();
            volume_card_controller2.saveP();
            volume_card_controller2.cancel();
            
            
            //ASI_CRM_AccountsAdditionalField__c customer = [SELECT id FROM ASI_CRM_AccountsAdditionalField__c LIMIT 1];
            //ApexPages.StandardController standardCtl = new ApexPages.StandardController(customer);
            ApexPages.currentpage().getparameters().put('id', customer.id);
            ASI_CRM_MY_AccountProsSegController controller_customer2 = new ASI_CRM_MY_AccountProsSegController(standardCtl);
            
            
            ApexPages.StandardController standardCtl_pros = new ApexPages.StandardController(pros);
            ApexPages.currentpage().getparameters().put('id', pros.id);
            ASI_CRM_MY_ProsSegmentationExt controller_pros = new ASI_CRM_MY_ProsSegmentationExt(standardCtl_pros);
            controller_pros.initSummary();
            controller_pros.getProsImageLevel();
            controller_pros.getProsVolumePotential();
            controller_pros.processGroupOutletType();
            controller_pros.processImageLevel();
            controller_pros.processVolumeCard();
            controller_pros.processAccountPlan();
            
            
            Map<Id, ASI_CRM_Pros_Segmentation__c> mapProsSegmentations = new Map<Id, ASI_CRM_Pros_Segmentation__c>();
            ASI_CRM_MY_ProsSegmentationClass.returnIdCard(customer.Id);
             Set<Id> accountIdSet = new Set<Id>();
            accountIdSet.add(customer.Id);
            ASI_CRM_MY_ProsSegmentationClass.returnIdCardMap(accountIdSet);
            mapProsSegmentations.put(pros.id, pros);
            Map<Id, ASI_CRM_ID_Card__c> mapIdCards = new Map<Id, ASI_CRM_ID_Card__c>();
            mapIdCards.put(customer.Id, card);
            ASI_CRM_MY_ProsSegmentationClass.assignImageLevel(mapProsSegmentations, mapIdCards);
            ASI_CRM_MY_ProsSegmentationClass.retrieveServicePack(pros);
            ASI_CRM_MY_ProsSegmentationClass.returnServicePackId(pros); 
            ASI_CRM_MY_ProsSegmentationClass.returnImageLevels(pros.ASI_CRM_SG_Group_Outlet_Type__c);
            ASI_CRM_MY_ProsSegmentationClass.returnVolumePotential(pros.ASI_CRM_SG_Group_Outlet_Type__c);
            ASI_CRM_MY_ProsSegmentationClass.resetServicePack(pros);
            ASI_CRM_MY_ProsSegmentationClass.returnSuperPremium(customer.Id);
            ASI_CRM_MY_ProsSegmentationClass.processCriteriaSheetModification(criteriaSet);
            
            Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaThresholds = new Map<Id, List<ASI_CRM_Criteria_Answer__c>>();
            List<ASI_CRM_Criteria_Answer__c> criteriaAnswerList = new List<ASI_CRM_Criteria_Answer__c>();
            criteriaAnswerList.add(criteriaAnswer);
            criteriaThresholds.put(criteriaAnswer.Id, criteriaAnswerList);
            ASI_CRM_MY_ProsSegmentationClass.processPicklistCriteriaSheetModification(criteriaSet, criteriaThresholds);
            
            Map<Id, ASI_CRM_ID_Card__c> idCards = new Map<Id, ASI_CRM_ID_Card__c>();
            idCards.put(card.Id, card);
            ASI_CRM_MY_ProsSegmentationClass.retrieveIDCardVolumeIndexMap(idCards);
            ASI_CRM_MY_ProsSegmentationClass.retrieveImageLevelCriteria(criteria_volume_set.Id);
            ASI_CRM_MY_ProsSegmentationClass.retrieveCriteriaAnswers(criteriaThreshold);
            List<ASI_CRM_Pros_Segmentation__c> prosSegmentationList = new List<ASI_CRM_Pros_Segmentation__c>();
            prosSegmentationList.add(pros);
            ASI_CRM_MY_ProsSegmentationClass.retrieveGroupOutletTypes(prosSegmentationList);
            
            ASI_CRM_MY_ProsSegmentationClass.resetProsSegmentation(pros);
            
            Test.stopTest();
            
            
             
        }

    }
    
    
    static testMethod void CreateAccountTest(){
        ASI_HK_CRM_Running_Number__c customerCodeRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Customer_Code', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = 'TH_A{000000}' );        
        try{
        insert customerCodeRunningNumber;
        } catch (System.DmlException e) {
        }
    
        ASI_HK_CRM_Running_Number__c contractRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Contract__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '{YY/YY}{0000}' );        
        try{
        insert contractRunningNumber;    
        } catch (System.DmlException e) {
        }
        
        ASI_HK_CRM_Running_Number__c paymentRequestRunningNumber= new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_PaymentRequest__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '60{YY}{0000}' );        
        try{
        insert paymentRequestRunningNumber;                    
        } catch (System.DmlException e) {
        }
                        
        User u = ASI_CRM_MY_TestClassHelper.createUser();                                                                 
        
        System.runAs(u) {
            List<Account> listAccount = new List<Account>();
            String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
            
            listAccount.add(new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid, ownerid = u.id));
            //listAccount.add(new Account(Name='Test Potential Outlet 2', ownerid = u.id));

            insert listAccount;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_TH_CRM_Potential_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_Account__c = listAccount[0].id, RecordTypeid = recordTypeid
            );
            insert accountAdditionalField;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c();
            insert(subChannel);
            
            recordTypeid = checkRecordType('ASI_CRM_Pros_Segmentation__c','ASI_CRM_TH_Pros_Segmentation');
            ASI_CRM_Pros_Segmentation__c prosSeg = new ASI_CRM_Pros_Segmentation__c(
                ASI_CRM_SG_Customer__c = accountAdditionalField.id, RecordTypeid = recordTypeid
            );
            insert prosSeg;
            
            accountAdditionalField.ASI_CRM_CN_Sub_Channel__c = subChannel.id;
            update accountAdditionalField;
        }
    }
    
    static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
            for (recordtype pl : sobjectlist ){
                if (pl.developername == rt_name)
                RT_id = pl.id;
            }
            system.debug('RT_id: ' + RT_id);
            return RT_id;
            
    }
    
    static testMethod void ASI_MFM_Plan_TriggerClass_SG_Test2() { 
        
    //ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_MY_TestClassHelper.createCustomer('customer4', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet');
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = 'customer Test',
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                    ASI_CRM_MY_CustomerCode__c = '123test',
                                  ASI_CRM_Active__c = true
                                                              );
        insert customer;
      } 
    

    
}