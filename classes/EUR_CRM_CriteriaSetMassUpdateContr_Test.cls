/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test class for EUR_CRM_CriteriaSetMassUpdateController.
  @Author:      IPC
  @History:     OCT.01.2014 - Created
*/
@isTest (seeAllData=false)
private class EUR_CRM_CriteriaSetMassUpdateContr_Test{
 
    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation2;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold2;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold3;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold4;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold5;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold6;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold7;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold8;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold9;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold10;
    private static EUR_CRM_Criteria_Set__c criteriaSetImgLevel;
    private static EUR_CRM_Criteria_Set__c criteriaSetVolPotential;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer2;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer3;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer4;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer5;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer6;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer7;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer8;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer9;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer10;
    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel2;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel3;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel4;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel5;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential2;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential3;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential4;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential5;
    
    private static List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdList;
    private static User accUser ;
    
    public static void dataInsert(){
            /*
            accUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@sales.com', 'testuser123902@sales.com', 'accTest1990');
            System.runAs(accUser){
            
            EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region 1', accUser.Id,'DE Region');
            
            EUR_CRM_Territory__c offTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('offTradeTerritory' , UserInfo.getUserId(), region.id, 'DE Territory');
            
            EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', '12345' , offTradeTerritory.id, 'DE Off Trade Postal Code - Territory Mapping');
            
            EUR_CRM_Customer_Taxonomy__c custTaxonomyOff = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'DE Customer Taxonomy');
            system.assertNotEquals(custTaxonomyOff, null);
           
            account= EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount1 ', '12345' , 'DE OFF STD', custTaxonomyOff.Id);
             */
            account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
        	account.EUR_CRM_Sub_Channel__c = 'Retail';
            insert account;
            criteriaSetImgLevel = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Image Level Criteria')[0];
            insert criteriaSetImgLevel;
            
            criteriaSetVolPotential = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Volume Potential Criteria')[0];
            insert criteriaSetVolPotential;
            
            groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR LT Group Outlet', 'EUR', criteriaSetImgLevel.Id, criteriaSetVolPotential.Id)[0];
            insert groupOutlet;
            
            prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_LT_PROS_Segmentation', 'EUR', account.Id, groupOutlet.Id, null, null, null, null)[0];
            insert prosSegmentation;
            
            criteriaThresholdList = new List<EUR_CRM_Criteria_Threshold__c>();
            List<EUR_CRM_Criteria_Answer__c> criteriaAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
            
            /************************
            Criteria Threshold
            ************************/
            criteriaThreshold = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Currency Input', criteriaSetImgLevel.Id)[0];
            criteriaThreshold.EUR_CRM_Question__c = 'Number of Super premium category';
            criteriaThreshold.EUR_CRM_isChanged__c = true;
            criteriaThresholdList.add(criteriaThreshold);
            
            //threshold for boolean
            criteriaThreshold2 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Yes/No', criteriaSetImgLevel.Id)[0];
            criteriaThreshold2.EUR_CRM_Question__c = 'TRUE of FALSE?';
            criteriaThreshold2.EUR_CRM_isChanged__c = true;
            criteriaThresholdList.add(criteriaThreshold2);
            
            //threshold for integer
            criteriaThreshold3 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Number Input', criteriaSetImgLevel.Id)[0];
            if(criteriaThreshold3.RecordTypeId == null)
                criteriaThreshold3 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Integer Input', criteriaSetImgLevel.Id)[0];
        
            criteriaThreshold3.EUR_CRM_Question__c = 'how many?';
            criteriaThreshold3.EUR_CRM_isChanged__c = true;
            criteriaThresholdList.add(criteriaThreshold3);
            
            //threshold for picklist
            criteriaThreshold4 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSetImgLevel.Id)[0];
            criteriaThreshold4.EUR_CRM_Question__c = 'how many?';
            criteriaThreshold4.EUR_CRM_isChanged__c = true;
            criteriaThresholdList.add(criteriaThreshold4);
            
            //threshold for Text
            criteriaThreshold5 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Text Input', criteriaSetImgLevel.Id)[0];
            criteriaThreshold5.EUR_CRM_Question__c = 'how many?';
            criteriaThreshold5.EUR_CRM_isChanged__c = true;
            criteriaThresholdList.add(criteriaThreshold5);
            
            criteriaThreshold6 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Currency Input', criteriaSetVolPotential.Id)[0];
            criteriaThreshold6.EUR_CRM_isChanged__c = true;
            criteriaThreshold6.EUR_CRM_Question__c = 'Number of Super premium category';
            
            criteriaThresholdList.add(criteriaThreshold6);
            
            //threshold for boolean
            criteriaThreshold7 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Yes/No', criteriaSetVolPotential.Id)[0];
            criteriaThreshold7.EUR_CRM_isChanged__c = true;
            criteriaThreshold7.EUR_CRM_Question__c = 'TRUE of FALSE?';
            
            criteriaThresholdList.add(criteriaThreshold7);
            
            //threshold for integer
            criteriaThreshold8 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Number Input', criteriaSetVolPotential.Id)[0];
            if(criteriaThreshold8.RecordTypeId == null)
                criteriaThreshold8 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Integer Input', criteriaSetImgLevel.Id)[0];
        
            criteriaThreshold8.EUR_CRM_Question__c = 'how many?';
            criteriaThreshold8.EUR_CRM_isChanged__c = true;
            criteriaThresholdList.add(criteriaThreshold8);
            
            //threshold for picklist
            criteriaThreshold9 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSetVolPotential.Id)[0];
            criteriaThreshold9.EUR_CRM_isChanged__c = true;
            criteriaThreshold9.EUR_CRM_Question__c = 'how many?';
            
            criteriaThresholdList.add(criteriaThreshold9);
            
            //threshold for Text
            criteriaThreshold10 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Text Input', criteriaSetVolPotential.Id)[0];
            criteriaThreshold10.EUR_CRM_isChanged__c = true;
            criteriaThreshold10.EUR_CRM_Question__c = 'how many?';
            
            criteriaThresholdList.add(criteriaThreshold10);
            
            insert criteriaThresholdList;
            
            
            /************************
            Criteria Answer
            ************************/
            criteriaAnswer = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Currency Input', criteriaThresholdList[0].Id)[0];
            criteriaAnswer.EUR_CRM_Condition__c = 'Greater Than (>)';
            //insert criteriaAnswer;
            criteriaAnswerList.add(criteriaAnswer);
            
            criteriaAnswer2 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Yes/No', criteriaThresholdList[1].Id)[0];
            criteriaAnswer2.EUR_CRM_Condition__c = 'Equal (=)';
            //insert criteriaAnswer2;
            criteriaAnswerList.add(criteriaAnswer2);
            
            criteriaAnswer3 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Integer Input', criteriaThresholdList[2].Id)[0];
            criteriaAnswer3.EUR_CRM_Condition__c = 'Greater Than (>)';
            //insert criteriaAnswer3;
            criteriaAnswerList.add(criteriaAnswer3);
            
            criteriaAnswer4 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Picklist', criteriaThresholdList[3].Id)[0];
            criteriaAnswer4.EUR_CRM_Condition__c = 'Equal (=)';
            //insert criteriaAnswer4;
            criteriaAnswerList.add(criteriaAnswer4);
            
            criteriaAnswer5 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Text Input', criteriaThresholdList[4].Id)[0];
            criteriaAnswer5.EUR_CRM_Condition__c = 'Equal (=)';
            //insert criteriaAnswer5;
            criteriaAnswerList.add(criteriaAnswer5);
            
            criteriaAnswer6 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Currency Input', criteriaThresholdList[5].Id)[0];
            criteriaAnswer6.EUR_CRM_Condition__c = 'Greater Than (>)';
            
            criteriaAnswerList.add(criteriaAnswer6);
            
            criteriaAnswer7 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Yes/No', criteriaThresholdList[6].Id)[0];
            criteriaAnswer7.EUR_CRM_Condition__c = 'Equal (=)';
            
            criteriaAnswerList.add(criteriaAnswer7);
            
            criteriaAnswer8 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Integer Input', criteriaThresholdList[7].Id)[0];
            criteriaAnswer8.EUR_CRM_Condition__c = 'Greater Than (>)';
            
            criteriaAnswerList.add(criteriaAnswer8);
            
            criteriaAnswer9 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Picklist', criteriaThresholdList[8].Id)[0];
            criteriaAnswer9.EUR_CRM_Condition__c = 'Equal (=)';
            
            criteriaAnswerList.add(criteriaAnswer9);
            
            criteriaAnswer10 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Text Input', criteriaThresholdList[9].Id)[0];
            criteriaAnswer10.EUR_CRM_Condition__c = 'Equal (=)';
            
            criteriaAnswerList.add(criteriaAnswer10);
            
            insert criteriaAnswerList;
      //  }        
    }
    
    public static testMethod void runtestDataImage(){
        dataInsert();
      //  System.runAs(accUser){
                /************************
                Image Level Threshold
                ************************/
                EUR_CRM_Image_Level__c imgLevel = new EUR_CRM_Image_Level__c();
                imgLevel.EUR_CRM_Group_Outlet_Type__c = groupOutlet.Id;
                insert imgLevel;
                
                EUR_CRM_Image_Level_Threshold__c imageThreshold = new EUR_CRM_Image_Level_Threshold__c();
                imageThreshold.EUR_CRM_Group_Outlet_Type__c = groupOutlet.Id;
                imageThreshold.EUR_CRM_Image_Level__c = imgLevel.Id;
                imageThreshold.EUR_CRM_Min_Weight__c = 0;
                imageThreshold.EUR_CRM_Name__c = 'Leading';
                imageThreshold.EUR_CRM_Is_Weight_Changed__c = true;
                insert imageThreshold;
                
                /************************
                PROS Image Level
                ************************/
                List<EUR_CRM_Pros_Image_Level__c> prosImgLevelList = new List<EUR_CRM_Pros_Image_Level__c>();
                
                prosImgLevel = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[0].Id)[0];
                prosImgLevel.EUR_CRM_Answer__c = '5';
                prosImgLevel.EUR_CRM_Weight__c = 10;
                //insert prosImgLevel;
                prosImgLevelList.add(prosImGLevel);
                
                prosImgLevel4 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[3].Id)[0];
                prosImgLevel4.EUR_CRM_Answer__c = 'Yes';
                prosImgLevel4.EUR_CRM_Weight__c = 10;
                //insert prosImgLevel4;
                prosImgLevelList.add(prosImGLevel4);
                
                prosImgLevel3 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[2].Id)[0];
                prosImgLevel3.EUR_CRM_Answer__c = '5';
                prosImgLevel3.EUR_CRM_Weight__c = 10;
                //insert prosImgLevel3;
                prosImgLevelList.add(prosImGLevel3);
                
                prosImgLevel2 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[1].Id)[0];
                prosImgLevel2.EUR_CRM_Answer__c = 'Yes';
                prosImgLevel2.EUR_CRM_Weight__c = 10;
                //insert prosImgLevel2;
                prosImgLevelList.add(prosImGLevel2);
                
                prosImgLevel5 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[4].Id)[0];
                prosImgLevel5.EUR_CRM_Answer__c = 'Yes';
                prosImgLevel5.EUR_CRM_Weight__c = 10; 
                //insert prosImgLevel5;
                prosImgLevelList.add(prosImGLevel5);
                
                insert prosImgLevelList;
            test.startTest();
                
                /************************
                Class method
                ************************/
                Set<Id> cSets = new Set<Id>();
                 Set<Id> grpOutletIds = new Set<Id>();
                
               for(EUR_CRM_Criteria_Threshold__c  thold : [SELECT Id, EUR_CRM_Criteria_Set__c, EUR_CRM_isChanged__c from EUR_CRM_Criteria_Threshold__c 
                       WHERE EUR_CRM_isChanged__c = true AND EUR_CRM_Criteria_Set__r.RecordType.DeveloperName like '%Image%']){
                       cSets.add(thold.EUR_CRM_Criteria_Set__c);
               }
               
               List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypeInfoList = [Select Id, EUR_CRM_Group_Outlet_Name__c, EUR_CRM_Image_Criteria_Set__r.Id 
                                            from EUR_CRM_Group_Outlet_Type__c where EUR_CRM_Image_Criteria_Set__r.Id IN: cSets];
                for (EUR_CRM_Group_Outlet_Type__c got : groupOutletTypeInfoList){
                        grpOutletIds.add(got.Id);
                    }
               List<EUR_CRM_Pros_Segmentation__c > prosSegList = [Select Id, EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Total_Image_Level_Weight__c,EUR_CRM_Total_Volume_Weight__c
                                from EUR_CRM_Pros_Segmentation__c 
                                where EUR_CRM_Group_Outlet_Type__c IN:grpOutletIds];
               List<EUR_CRM_Image_Level_Threshold__c > tholds= [select id,EUR_CRM_Is_Weight_Changed__c ,EUR_CRM_Image_Level__c,EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Min_Weight__c from EUR_CRM_Image_Level_Threshold__c where EUR_CRM_Group_Outlet_Type__c IN:grpOutletIds];
               system.assert(cSets.size() >0);
               system.assert(groupOutletTypeInfoList.size() >0);
               system.assert(prosSegList!= null);
               system.assert(prosSegList.size() > 0);
               system.assert(prosSegList.size() == 1);
               system.assert(tholds.size() == 1);
               system.assert(prosSegList[0].EUR_CRM_Total_Image_Level_Weight__c > 0);
             //   processImageLevelThreshold(prosSegList );     
               EUR_CRM_MassUpdateCriteriaSetBatch CSBatch= new EUR_CRM_MassUpdateCriteriaSetBatch();
                CSBatch.runImageBatchJob();
            test.stopTest();
      //  }
    } 
    public static testMethod void runtestDataVolume(){
        dataInsert();
     //   System.runAs(accUser){
            test.startTest();
                EUR_CRM_Volume_Potential__c volPot= new EUR_CRM_Volume_Potential__c();
                volPot.EUR_CRM_Group_Outlet_Type__c = groupOutlet.Id;
                insert volPot;
                
                EUR_CRM_Volume_Potential_Threshold__c volPotThreshold= new EUR_CRM_Volume_Potential_Threshold__c();
                volPotThreshold.EUR_CRM_Group_Outlet_Type__c = groupOutlet.Id;
                volPotThreshold.EUR_CRM_Volume_Potential__c= volPot.Id;
                volPotThreshold.EUR_CRM_Min_Weight__c = 0;
                volPotThreshold.EUR_CRM_Name__c = 'High';
                volPotThreshold.EUR_CRM_Is_Weight_Changed__c = true;
                insert volPotThreshold;
                /************************
                PROS Volume Level
                ************************/
                List<EUR_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<EUR_CRM_Pros_Volume_Potential__c>();
                
                prosVolPotential = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[5].Id)[0];
                prosVolPotential.EUR_CRM_Answer__c = '5';
                prosVolPotential.EUR_CRM_Weight__c = 10;
                prosVolPotentialList.add(prosVolPotential);
                
                prosVolPotential2 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[6].Id)[0];
                prosVolPotential2.EUR_CRM_Answer__c = '5';
                prosVolPotential2.EUR_CRM_Weight__c = 10;
                prosVolPotentialList.add(prosVolPotential2);
                
                prosVolPotential3 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[7].Id)[0];
                prosVolPotential3.EUR_CRM_Answer__c = '5';
                prosVolPotential3.EUR_CRM_Weight__c = 10;
                prosVolPotentialList.add(prosVolPotential3);
                
                prosVolPotential4 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[8].Id)[0];
                prosVolPotential4.EUR_CRM_Answer__c = '5';
                prosVolPotential4.EUR_CRM_Weight__c = 10;
                prosVolPotentialList.add(prosVolPotential4);
                
                prosVolPotential5 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[9].Id)[0];
                prosVolPotential5.EUR_CRM_Answer__c = '5';
                prosVolPotential5.EUR_CRM_Weight__c = 10;
                prosVolPotentialList.add(prosVolPotential5);
                
                insert prosVolPotentialList;
                
                /************************
                Class method
                ************************/
                EUR_CRM_MassUpdateCriteriaSetBatch CSBatch = new EUR_CRM_MassUpdateCriteriaSetBatch();
               CSBatch.runVolumeBatchJob();
            test.stopTest();
       // }
    }
    
       public static void processImageLevelThreshold(List<EUR_CRM_Pros_Segmentation__c> prosSegmentations){
        system.debug('!!! ' + prosSegmentations);
        Set<Id> groupOutletSet = new Set<Id>();
        for(EUR_CRM_Pros_Segmentation__c pros : prosSegmentations){
            groupOutletSet.add(pros.EUR_CRM_Group_Outlet_Type__c);
        }
        Map<Id,List<EUR_CRM_Image_Level_Threshold__c>> groupOutletImageLevelThresholds = new Map<Id,List<EUR_CRM_Image_Level_Threshold__c>>();
        List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholdsUpdated = new List<EUR_CRM_Image_Level_Threshold__c>();
        for(EUR_CRM_Image_Level_Threshold__c imageLevelThreshold : [select id,EUR_CRM_Is_Weight_Changed__c ,EUR_CRM_Image_Level__c,EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Min_Weight__c from EUR_CRM_Image_Level_Threshold__c where EUR_CRM_Group_Outlet_Type__c in : groupOutletSet]){
            if(groupOutletImageLevelThresholds.get(imageLevelThreshold.EUR_CRM_Group_Outlet_Type__c) == null)
                groupOutletImageLevelThresholds.put(imageLevelThreshold.EUR_CRM_Group_Outlet_Type__c, new List<EUR_CRM_Image_Level_Threshold__c>());
            groupOutletImageLevelThresholds.get(imageLevelThreshold.EUR_CRM_Group_Outlet_Type__c).add(imageLevelThreshold);
            
            if(imageLevelThreshold.EUR_CRM_Is_Weight_Changed__c)
                imageLevelThresholdsUpdated.add (new EUR_CRM_Image_Level_Threshold__c (id = imageLevelThreshold.id,  EUR_CRM_Is_Weight_Changed__c = false));
        }
        List<EUR_CRM_Pros_Segmentation__c> prosUpdated = new List<EUR_CRM_Pros_Segmentation__c >();
        for(EUR_CRM_Pros_Segmentation__c pros : prosSegmentations){
            EUR_CRM_Image_Level_Threshold__c threshold = retriveImageLevelThreshold(pros.EUR_CRM_Total_Image_Level_Weight__c, groupOutletImageLevelThresholds.get(pros.EUR_CRM_Group_Outlet_Type__c));
                prosUpdated.add(new EUR_CRM_Pros_Segmentation__c(id = pros.id, EUR_CRM_Image_Level_Threshold__c = threshold.id , EUR_CRM_Image_Level__c = threshold.EUR_CRM_Image_Level__c ));
        }
        Savepoint sp = Database.setSavepoint();

        try{
           // update prosUpdated;
          //  update imageLevelThresholdsUpdated;
        }catch(Exception e){
            Database.rollback(sp);

        } 
    }
    
    public static EUR_CRM_Image_Level_Threshold__c retriveImageLevelThreshold(Decimal weight, List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholds){
        Decimal tempWeight= 0;
        EUR_CRM_Image_Level_Threshold__c tempThreshold = null;
        for(EUR_CRM_Image_Level_Threshold__c imageLevelThreshold  : imageLevelThresholds){
            if(weight >= imageLevelThreshold.EUR_CRM_Min_Weight__c && tempWeight<= imageLevelThreshold.EUR_CRM_Min_Weight__c){
                tempWeight= imageLevelThreshold.EUR_CRM_Min_Weight__c;
                tempThreshold = imageLevelThreshold ;
            }
        } 
        system.debug('!!! th ' + tempThreshold.EUR_CRM_Min_Weight__c );
        system.debug('!!! weight' + weight);
        return tempThreshold ;
    }
    
}