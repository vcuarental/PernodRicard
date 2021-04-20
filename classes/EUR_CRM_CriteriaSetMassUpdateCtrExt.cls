public with sharing class EUR_CRM_CriteriaSetMassUpdateCtrExt {
    
    private ApexPages.StandardController stdCon;
    private EUR_CRM_CriteriaManager mgr {get;set;}
    private Double total;
    private Double answerWeight;
    
    private List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypeInfoList;
    private List<EUR_CRM_Pros_Segmentation__c> prosSegList;
    
    private List<EUR_CRM_Criteria_Set__c> criteriaSetInfoList;
    private Map<Id, EUR_CRM_Criteria_Threshold__c> criteriaThresholds; 
    private List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdsList{get;set;}
    
    private List<EUR_CRM_Criteria_Answer__c> answers;
    private Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaAnswers;
    
    private Map<Id, EUR_CRM_Pros_Image_Level__c> imageLevelMap{get;set;}{imageLevelMap = new Map<Id, EUR_CRM_Pros_Image_Level__c>();}
    private Map<Id, EUR_CRM_Pros_Volume_Potential__c> volumePotentialMap{get;set;}{volumePotentialMap = new Map<Id, EUR_CRM_Pros_Volume_Potential__c>();}
    
    private List<EUR_CRM_Pros_Image_Level__c>newImageLevels;
    private List<EUR_CRM_Pros_Volume_Potential__c>newVolumePotentials;   
    
    public  EUR_CRM_Pros_Image_Level__c accountCriteria;
    
    public Map<Id, String> answerSheet{get;set;}
    public String cSetId;
    public EUR_CRM_Criteria_Set__c cset {get;set;}
    public Set<Id> prosSetId;
    private Set<Id> caImgLvlSetIds;
    public Map<Id, EUR_CRM_Pros_Segmentation__c> prosSegIdMap;
    
    private Boolean isImage;
    private Boolean isVol;
    private Set<ID> toDeleteImageIDs;
    private Set<ID> toDeleteVolumeIDs;
    
    public EUR_CRM_CriteriaSetMassUpdateCtrExt(ApexPages.StandardController controller) {
        
        toDeleteImageIDs  = new Set<ID>();
        toDeleteVolumeIDs  = new Set<ID>();
        stdCon = controller;
        cSetId = stdCon.getId();
        //mgr = new EUR_CRM_CriteriaManager();
        newImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
        newVolumePotentials = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        system.debug('@@@CSETID' + cSetId);  
    }
    
    public PageReference massUpdate(){
        
        Pagereference pr = new Pagereference('/'+cSetId);
        pr.setRedirect(true);
        
        init();
        return pr;
    }
    
    public void init(){
        //cset = stdCon.getRecord();
        isImage = false;
        isVol   = false;
        Set<Id> grpOutletIds = new Set<Id>();
        prosSetId = new Set<Id>();
        caImgLvlSetIds = new Set<Id>();
        List<EUR_CRM_Criteria_Set__c> csetList = new List<EUR_CRM_Criteria_Set__c>();
        groupOutletTypeInfoList = new List<EUR_CRM_Group_Outlet_Type__c>();
        prosSegList = new List<EUR_CRM_Pros_Segmentation__c>();
        
        csetList = [Select Id, RecordType.DeveloperName from EUR_CRM_Criteria_Set__c where Id =: cSetId];
        
        prosSegIdMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>();
        
        system.debug('@@csetList' + csetList);
        system.debug('csetRec.RecordType.DeveloperName.contains' + csetList[0].RecordType.DeveloperName.contains('Image'));
        if (csetList[0].RecordType.DeveloperName.contains('Image')){
            groupOutletTypeInfoList = [Select Id, EUR_CRM_Group_Outlet_Name__c, EUR_CRM_Image_Criteria_Set__r.Id 
                                        from EUR_CRM_Group_Outlet_Type__c where EUR_CRM_Image_Criteria_Set__r.Id =: cSetId];
            
            isImage = true;                     
            //system.debug('groupOutletTypeInfoList1' + groupOutletTypeInfoList);           
        }
        if (csetList[0].RecordType.DeveloperName.contains('Volume')){
            groupOutletTypeInfoList = [Select Id, EUR_CRM_Group_Outlet_Name__c, EUR_CRM_Image_Criteria_Set__r.Id 
                                        from EUR_CRM_Group_Outlet_Type__c where EUR_CRM_Volume_Criteria_Set__r.Id =: cSetId];
            
            isVol = true;
            //system.debug('groupOutletTypeInfoList2' + groupOutletTypeInfoList);
        }
        
        for (EUR_CRM_Group_Outlet_Type__c got : groupOutletTypeInfoList){
            grpOutletIds.add(got.Id);
        }
        system.debug('grpOutletIds' + grpOutletIds);
        if (grpOutletIds != null){ 
            prosSegList = [Select Id, EUR_CRM_Group_Outlet_Type__c from EUR_CRM_Pros_Segmentation__c 
                                where EUR_CRM_Group_Outlet_Type__c IN:grpOutletIds];
        }
        
        if (prosSegList != null){
            for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
                prosSetId.add(eupros.Id);
                prosSegIdMap.put(eupros.Id, eupros);
            }
            //system.debug('prosSegIdMap' + prosSegIdMap);
        }
        //
        Boolean isMassUpdateImg = false;
        Boolean isMassUpdaseVol = false;
        if (groupOutletTypeInfoList != null){
            if (isImage){
                //returnImageLevelMap();
                calculateBoolean();
                calculateInteger();
                calculatePicklist();
                calculateCurrency();
                calculateText();
                
                isMassUpdateImg = true;
            }
            
            if (isVol){
                system.debug('run code here1');
                //returnVolumePotentialMap();
                calculateBooleanVol();
                calculateIntegerVol();
                calculatePicklistVol();
                calculateCurrencyVol();
                calculateTextVol();
                
                isMassUpdaseVol = true;
            }
            //deleteOldPros();
            //deleteObjects();
            if (isMassUpdaseVol || isMassUpdateImg){
                for (EUR_CRM_Criteria_Set__c cs: csetList){
                    cs.EUR_CRM_Last_Mass_Update_Date__c = Datetime.now();
                }
                
                update csetList;
            }
        } 
    }
    
    
    /*Begin Re calculation methods*/
    //Calculate Image Levels
    public void calculateBoolean(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapBool = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevel2 = null;
        
        ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Boolean'];
        system.debug('ctListDevName' + ctList.size()); 
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            //prosSetId.add(eupros.Id);
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);

        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        newImageLevels  = new List<EUR_CRM_Pros_Image_Level__c>();
        if(ctIds.size()>0){
        newImageLevels = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName   from EUR_CRM_Pros_Image_Level__c
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds //and EUR_CRM_Is_Mass_Update__c = true
                                    ORDER BY EUR_CRM_Weight__c];
        }
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempBool = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds]; 
                        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempBool){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapBool.containsKey(key))?cAnswerMapBool.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapBool.put(key,ansList);
        }
        
        Double answerWeight = 0;
        updateListProsSegImgLevel2 = new List<EUR_CRM_Pros_Image_Level__c>();
        Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        Map<Id,EUR_CRM_Criteria_Answer__c> criteriaAnsMap = new Map<Id,EUR_CRM_Criteria_Answer__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            thresholdWeightMap.put(e.Id, e);
        }
        
        system.debug('thresholdWeightMap' + thresholdWeightMap);
        for (EUR_CRM_Pros_Image_Level__c p : newImageLevels){
            EUR_CRM_Pros_Image_Level__c prosImg = new EUR_CRM_Pros_Image_Level__c();
            //p.Id = p.Id;
            prosImg.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            prosImg.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            prosImg.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // prosImg.EUR_CRM_Is_Mass_Update__c = true;
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapBool.get(p.EUR_CRM_Criteria_Threshold__c) ){     
                system.debug('MapWeight' + thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c);
                //system.debug('MapAnswer' + criteriaAnsMap.get.(EUR_CRM_Value__c));
                ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null)?ca.EUR_CRM_Value__c:'';
                if (thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Boolean')){
                    if (ca.EUR_CRM_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Weight__c * thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;//e.EUR_CRM_Weight__c;
                    }
                        
                }
                   
            }
            system.debug('#####answerWeight' + answerWeight/100);
            prosImg.EUR_CRM_Weight__c = answerWeight/100;
            
            updateListProsSegImgLevel2.add(prosImg);
        }
        
        List<EUR_CRM_Pros_Image_Level__c> toUpdateProsImageList = new List<EUR_CRM_Pros_Image_Level__c>();
        toUpdateProsImageList = [Select Id, //EUR_CRM_Is_Mass_Update__c, 
                                 EUR_CRM_Pros_Segmentation__c from EUR_CRM_Pros_Image_Level__c 
                                where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset() //and EUR_CRM_Is_Mass_Update__c = true
                                 ];
                                
        for (EUR_CRM_Pros_Image_Level__c ep : toUpdateProsImageList ){
           // ep.EUR_CRM_Is_Mass_Update__c = false;
            toDeleteImageIDs.add(ep.id);
        }
        //update toUpdateProsImageList;
        
        if (updateListProsSegImgLevel2.size() > 0){
            insert updateListProsSegImgLevel2;
            
            system.debug('@@@BooleanInsert' + updateListProsSegImgLevel2.size());
        }   
        
        
    }
    
    public void calculateInteger(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMap = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelInt = null;
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelInt2 = null;
        ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Integer_Input'];
        system.debug('ctListDevNameInt' + ctList.size()); 
        Double answerWeight = 0;
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            //prosSetId.add(eupros.Id);
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMapInt = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);
            thresholdWeightMapInt.put(e.Id, e);
  
        }
        
        system.debug('thresholdWeightMapInt' + thresholdWeightMapInt);
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateListProsSegImgLevelInt = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevelInt2 = new List<EUR_CRM_Pros_Image_Level__c>();
        
        updateListProsSegImgLevelInt  = new List<EUR_CRM_Pros_Image_Level__c>();
        if(ctIds.size()>0){
        updateListProsSegImgLevelInt = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Statement__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                            EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName   from EUR_CRM_Pros_Image_Level__c
                                                where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds ORDER BY EUR_CRM_Weight__c];
        }
        system.debug('@@updateListProsSegImgLevelInt' + updateListProsSegImgLevelInt);
        system.debug('@@updateListProsSegImgLevelInt' + updateListProsSegImgLevelInt.size());
        
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTemp = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds]; 
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTemp){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMap.containsKey(key))?cAnswerMap.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMap.put(key,ansList);
        }
                        
        for (EUR_CRM_Pros_Image_Level__c p : updateListProsSegImgLevelInt){
            EUR_CRM_Pros_Image_Level__c prosImg = new EUR_CRM_Pros_Image_Level__c();    
            
            system.debug('MapWeightInt' + thresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c);
            system.debug('MapWeightIntRec' + thresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Integer_Input'));
            prosImg.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            prosImg.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            prosImg.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // prosImg.EUR_CRM_Is_Mass_Update__c = true;
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMap.get(p.EUR_CRM_Criteria_Threshold__c)){

                Boolean bool = false;
                if (thresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Integer_Input')){
                    if (ca.EUR_CRM_Condition__c!=null){
                        String condition = ca.EUR_CRM_Condition__c;
                        condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                        //System.debug('Flag-Condition: ' + condition + '|' + ans);
                      
                        if(p.EUR_CRM_Answer__c==null || p.EUR_CRM_Answer__c== '')
                            p.EUR_CRM_Answer__c = '0';
                            
                        Integer answer = Integer.valueOf(p.EUR_CRM_Answer__c);
                        system.debug('##AnswerInt' + answer);
                        if (condition.equalsIgnorecase('='))
                        {
                            bool = (answer == ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('!='))
                        {
                            bool = (answer != ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<'))
                        {
                            bool = (answer < ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>'))
                        {
                            bool = (answer > ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<='))
                        {
                            bool = (answer <= ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>='))
                        {
                            bool = (answer >= ca.EUR_CRM_Base_Integer__c) ? true: false;
                        } 
                    }   
                }
                
                if(bool){
                    //System.debug('Flag - Ans Weight:' + answerOption.EUR_CRM_Weight__c + '-' + answerOption.EUR_CRM_Weight__c * thresholdWeight);
                    answerWeight = ca.EUR_CRM_Weight__c * thresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    system.debug('#####answerWeightforInt 1:' + answerWeight/100);
                }    
                            
            }
            
            prosImg.EUR_CRM_Weight__c = answerWeight/100;   
            system.debug('#####answerWeightforInt:' + answerWeight/100 +'-'+ prosImg.EUR_CRM_Weight__c);    
            updateListProsSegImgLevelInt2.add(prosImg); 
            
        }                                       
        system.debug('IntUpdateProsImg::' + updateListProsSegImgLevelInt2);
        if (updateListProsSegImgLevelInt2.size() > 0){
            insert updateListProsSegImgLevelInt2;
        }
        
        //update updateListProsSegImgLevelInt;
        
        system.debug('@@@@updateListProsSegImgLevel2' + updateListProsSegImgLevelInt.size());                           
    }
    
    public void calculatePicklist(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapPick = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelPick = null;
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelPick2 = null;
        
        //ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
        //          where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Picklist'];
        system.debug('ctListDevNameInt' + ctList.size()); 
        Double answerWeight = 0;
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            //prosSetId.add(eupros.Id);
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Threshold__c e: [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                                                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Picklist']){
            ctIds.add(e.Id);
            thresholdWeightMap.put(e.Id, e);
            
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateListProsSegImgLevelPick = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevelPick2 = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevelPick = new List<EUR_CRM_Pros_Image_Level__c>();
        if(ctIds.size()>0){
        updateListProsSegImgLevelPick = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                            EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName from EUR_CRM_Pros_Image_Level__c
                                                where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds ORDER BY EUR_CRM_Weight__c];
          }                          
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempPick = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds];     
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempPick){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapPick.containsKey(key))?cAnswerMapPick.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapPick.put(key,ansList);
        }
                        
        for (EUR_CRM_Pros_Image_Level__c p : updateListProsSegImgLevelPick){
            EUR_CRM_Pros_Image_Level__c prosImg = new EUR_CRM_Pros_Image_Level__c();
            prosImg.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            prosImg.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            prosImg.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // prosImg.EUR_CRM_Is_Mass_Update__c = true;
        
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapPick.get(p.EUR_CRM_Criteria_Threshold__c)){                      
                if (thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Picklist')){
                    ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null)?ca.EUR_CRM_Value__c:'';
                    if (ca.EUR_CRM_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Weight__c * thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    }   
                        
                }
            }
            prosImg.EUR_CRM_Weight__c = answerWeight/100;       
            updateListProsSegImgLevelPick2.add(prosImg);
        }
        
        system.debug('PickUpdateProsImg::' + updateListProsSegImgLevelPick2);
        if (updateListProsSegImgLevelPick2.size() > 0){
            insert updateListProsSegImgLevelPick2;
        }
        system.debug('@@@@updateListProsSegImgLevel2' + updateListProsSegImgLevelPick2.size()); 
    }
    
    public void calculateCurrency(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapCurr = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelCurr = null;
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelCurr2 = null;
        
        ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Currency_Input'];
        system.debug('ctListDevNameCurr' + ctList.size()); 
        Double answerWeight = 0;
         Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);
            thresholdWeightMap.put(e.Id, e);
    
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        updateListProsSegImgLevelCurr = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevelCurr2 = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevelCurr = new List<EUR_CRM_Pros_Image_Level__c>();
        if(ctIds.size()>0){
        updateListProsSegImgLevelCurr = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName   from EUR_CRM_Pros_Image_Level__c
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds ORDER BY EUR_CRM_Weight__c];
        }
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempCurr = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c, EUR_CRM_Base_Currency__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds]; 
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempCurr){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapCurr.containsKey(key))?cAnswerMapCurr.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapCurr.put(key,ansList);
        }                                           
        
        for (EUR_CRM_Pros_Image_Level__c p : updateListProsSegImgLevelCurr){
            EUR_CRM_Pros_Image_Level__c prosImg = new EUR_CRM_Pros_Image_Level__c();
            prosImg.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            prosImg.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            prosImg.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // prosImg.EUR_CRM_Is_Mass_Update__c = true;
                    
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapCurr.get(p.EUR_CRM_Criteria_Threshold__c) ){
                Boolean bool = false;
                if (thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Currency_Input')){   
                    if (ca.EUR_CRM_Condition__c != null){
                        String condition = ca.EUR_CRM_Condition__c;
                        condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                            
                        if(p.EUR_CRM_Answer__c==null || p.EUR_CRM_Answer__c== '')
                            p.EUR_CRM_Answer__c = '0';
                                
                        Double answer = Double.valueOf(p.EUR_CRM_Answer__c);                    
                        
                        if (condition.equalsIgnorecase('='))
                        {
                            bool = (answer == ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('!='))
                        {
                            bool = (answer != ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<'))
                        {
                            bool = (answer < ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>'))
                        {
                            bool = (answer > ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<='))
                        {
                            bool = (answer <= ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>='))
                        {
                            bool = (answer >= ca.EUR_CRM_Base_Currency__c) ? true: false;
                        } 
                    }
                }
                if(bool){
                    answerWeight = ca.EUR_CRM_Weight__c * thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                }
            }
            prosImg.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegImgLevelCurr2.add(prosImg);
                
        }
        system.debug('@@@updateListProsSegImgLevelCurr1' + updateListProsSegImgLevelCurr);  
        if (updateListProsSegImgLevelCurr2.size() > 0){
            insert updateListProsSegImgLevelCurr2;
        }
            
        system.debug('@@@updateListProsSegImgLevelCurr' + updateListProsSegImgLevelCurr.size());                        
    }
    
    public void calculateText(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapText = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelText = null;
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelText2 = null;
        
        ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Text_Input'];
        system.debug('ctListDevNameText' + ctList.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);
            thresholdWeightMap.put(e.Id, e);
    
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        updateListProsSegImgLevelText = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevelText2 = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevelText = new List<EUR_CRM_Pros_Image_Level__c>();
        if(ctIds.size()>0){
        updateListProsSegImgLevelText = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName   from EUR_CRM_Pros_Image_Level__c
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds ORDER BY EUR_CRM_Weight__c];    
        }
        //List<EUR_CRM_Criteria_Answer__c> cAnswerListTempTxt = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
        //              where EUR_CRM_Criteria_Threshold__c IN: ctIds];  
        
        /*for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempTxt){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapText.containsKey(key))?cAnswerMapText.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapText.put(key,ansList);
        }*/
                                                    
        for (EUR_CRM_Pros_Image_Level__c p : updateListProsSegImgLevelText){
            EUR_CRM_Pros_Image_Level__c prosImg = new EUR_CRM_Pros_Image_Level__c();
            prosImg.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            prosImg.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            prosImg.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // prosImg.EUR_CRM_Is_Mass_Update__c = true;
            
            /*Boolean isText = false;
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapText.get(p.EUR_CRM_Criteria_Threshold__c) ){  
                if (thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Text_Input')){               
                    isText = true;
                    
                }
            }*/
            if (thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Text_Input')){               
                //isText = true;
                prosImg.EUR_CRM_Weight__c = 0;      
            }
            //if (isText)
            
            updateListProsSegImgLevelText2.add(prosImg);    
        }
                
        if (updateListProsSegImgLevelText2.size() > 0){         
            insert updateListProsSegImgLevelText2;
        }
    }
    
    //Calculate Volume Potentials
    public void calculateBooleanVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListBoolean = null;
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListBoolean2 = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapBooleanVol = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        
        //ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
        //          where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Boolean'];
        //system.debug('ctListVolBoolean' + ctList.size()); 
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                                                where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Boolean']){
            system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);
            volThresholdWeightMap.put(e.Id, e);
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListBoolean = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListBoolean2 = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
         updateProsVolPotentialListBoolean = new List<EUR_CRM_Pros_Volume_Potential__c>();
        if(ctIds.size()>0){
        updateProsVolPotentialListBoolean = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                                EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName   from EUR_CRM_Pros_Volume_Potential__c
                                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                                        and EUR_CRM_Criteria_Threshold__c IN: ctIds 
                                                        //and EUR_CRM_Is_Mass_Update__c = true 
                                                        ORDER BY EUR_CRM_Weight__c];
        }
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempBool = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds]; 
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempBool){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapBooleanVol.containsKey(key))?cAnswerMapBooleanVol.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapBooleanVol.put(key,ansList);
        }
        
        Double answerWeight = 0;
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListBoolean){   
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            //p.Id = p.Id;
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // pv.EUR_CRM_Is_Mass_Update__c = true; 
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapBooleanVol.get(p.EUR_CRM_Criteria_Threshold__c)){    
                ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null)?ca.EUR_CRM_Value__c:'';
                if (volThresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Boolean')){
                    if (ca.EUR_CRM_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Weight__c * volThresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    }   
                }                       
            }
            system.debug('#####answerWeight' + answerWeight/100);
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updateProsVolPotentialListBoolean2.add(pv); 
        }
        
        if (updateProsVolPotentialListBoolean2.size() > 0){
            insert updateProsVolPotentialListBoolean2;
        }
        system.debug('@@@@updateProsVolPotentialListBoolean' + updateProsVolPotentialListBoolean2);
    }
    
    public void calculateIntegerVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListInt = null;
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListInt2 = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapIntVol = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        
        //ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
        //          where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Integer_Input'];
        //system.debug('ctListDevNameIntvOL' + ctList); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapInt = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
       /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            //prosSetId.add(eupros.Id);
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                                                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Integer_Input']){
            ctIds.add(e.Id);
            volThresholdWeightMapInt.put(e.Id, e);
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListInt = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListInt2 = new List<EUR_CRM_Pros_Volume_Potential__c>();
         updateProsVolPotentialListInt = new List<EUR_CRM_Pros_Volume_Potential__c>();
        if(ctIds.size()>0){
        updateProsVolPotentialListInt = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                            EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName //, EUR_CRM_Is_Mass_Update__c 
                                            from EUR_CRM_Pros_Volume_Potential__c
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds // and EUR_CRM_Is_Mass_Update__c = true 
                                    ORDER BY EUR_CRM_Weight__c];
                                    }
        system.debug('updateProsVolPotentialListInt' + updateProsVolPotentialListInt.size());   
        
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempInt = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds]; 
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempInt){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapIntVol.containsKey(key))?cAnswerMapIntVol.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapIntVol.put(key,ansList);
        }                   
        
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListInt){
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            //p.Id = p.Id;  
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // pv.EUR_CRM_Is_Mass_Update__c = true; 
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapIntVol.get(p.EUR_CRM_Criteria_Threshold__c)){    
                Boolean bool = false;
                if (volThresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Integer_Input')){
                    if (ca.EUR_CRM_Condition__c!=null){
                        String condition = ca.EUR_CRM_Condition__c;
                        condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                        System.debug('Flag-Condition: ' + condition);
                       
                        if(p.EUR_CRM_Answer__c==null || p.EUR_CRM_Answer__c== '')
                            p.EUR_CRM_Answer__c = '0';
                            
                        Integer answer = Integer.valueOf(p.EUR_CRM_Answer__c);
                        system.debug('Vol Ans::' + answer);
                        if (condition.equalsIgnorecase('='))
                        {
                            bool = (answer == ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('!='))
                        {
                            bool = (answer != ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<'))
                        {
                            bool = (answer < ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>'))
                        {
                            bool = (answer > ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<='))
                        {
                            bool = (answer <= ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>='))
                        {
                            bool = (answer >= ca.EUR_CRM_Base_Integer__c) ? true: false;
                        }
                        system.debug('BOOL' + bool);
                       
                    }
                }
                if(bool){
                    //System.debug('Flag - Ans Weight:' + answerOption.EUR_CRM_Weight__c + '-' + answerOption.EUR_CRM_Weight__c * thresholdWeight);
                    answerWeight = ca.EUR_CRM_Weight__c * volThresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    system.debug('****AnswerWeight' + answerWeight);
                }
            }           
            system.debug('#####answerWeight2' + answerWeight/100);
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updateProsVolPotentialListInt2.add(pv);
        }
        
        List<EUR_CRM_Pros_Volume_Potential__c> toUpdateProsVolList = new List<EUR_CRM_Pros_Volume_Potential__c>();
        toUpdateProsVolList = [Select Id,// EUR_CRM_Is_Mass_Update__c,
                             EUR_CRM_Pros_Segmentation__c from EUR_CRM_Pros_Volume_Potential__c 
                                where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()];
        system.debug('#toUpdateProsVolList' + toUpdateProsVolList);                     
        for (EUR_CRM_Pros_Volume_Potential__c ep : toUpdateProsVolList ){
           // ep.EUR_CRM_Is_Mass_Update__c = false;
            toDeleteVolumeIDs.add(ep.id);
        }
        if (toUpdateProsVolList.size() > 0){
           // update toUpdateProsVolList;
        }
        
        system.debug('updateProsVolPotentialListInt2' + updateProsVolPotentialListInt2);
        if(updateProsVolPotentialListInt2.size() > 0){
            insert updateProsVolPotentialListInt2;  
        }
        
        system.debug('@@@@updateProsVolPotentialListInt2' + updateProsVolPotentialListInt2.size());                         
    }
    
    public void calculatePicklistVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListPick = null;
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListPick2 = null; 
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapIntVol = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        
        //ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
        //          where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Picklist'];
        //system.debug('ctListDevNamePick' + ctList.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapPick = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            //prosSetId.add(eupros.Id);
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                                                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Picklist']){
            ctIds.add(e.Id);
            volThresholdWeightMapPick.put(e.Id, e);
        }
        
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        updateProsVolPotentialListPick = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListPick2 = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        updateProsVolPotentialListPick = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName from EUR_CRM_Pros_Volume_Potential__c
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds // and EUR_CRM_Is_Mass_Update__c = true
                                    ORDER BY EUR_CRM_Weight__c];
        
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempPick = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds];     
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempPick){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapIntVol.containsKey(key))?cAnswerMapIntVol.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapIntVol.put(key,ansList);
        }               

        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListPick){
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            //p.Id = p.Id;
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // pv.EUR_CRM_Is_Mass_Update__c = true; 
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapIntVol.get(p.EUR_CRM_Criteria_Threshold__c)){                
                if (volThresholdWeightMapPick.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Picklist')){
                    ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null)?ca.EUR_CRM_Value__c:'';
                    if (ca.EUR_CRM_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Weight__c * volThresholdWeightMapPick.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    }                           
                }
            }
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updateProsVolPotentialListPick2.add(pv);
        }

        if (updateProsVolPotentialListPick2.size() > 0){
            insert updateProsVolPotentialListPick2;
        }
        
        system.debug('@@@@updateListProsSegImgLevel2' + updateProsVolPotentialListPick2.size());        
    }
    
    public void calculateCurrencyVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListCurr = null;
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListCurr2 = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapVolCurr = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        
        //ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
        //          where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Currency_Input'];
        //system.debug('ctListDevNameCurr' + ctList.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapCurr = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                                                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Currency_Input']){
            ctIds.add(e.Id);
            volThresholdWeightMapCurr.put(e.Id, e);
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListCurr = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListCurr2 = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListCurr = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName from EUR_CRM_Pros_Volume_Potential__c
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds //and EUR_CRM_Is_Mass_Update__c = true 
                                    ORDER BY EUR_CRM_Weight__c ];
        
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempCurr = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c, EUR_CRM_Base_Currency__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds]; 
                        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempCurr){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapVolCurr.containsKey(key))?cAnswerMapVolCurr.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapVolCurr.put(key,ansList);
        }               
                                                    
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListCurr){
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            //p.Id = p.Id;
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // pv.EUR_CRM_Is_Mass_Update__c = true; 
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapVolCurr.get(p.EUR_CRM_Criteria_Threshold__c)){   
                Boolean bool = false;
                if (volThresholdWeightMapCurr.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Currency_Input')){
                    if (ca.EUR_CRM_Condition__c != null){
                        String condition = ca.EUR_CRM_Condition__c;
                        condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                                
                        if(p.EUR_CRM_Answer__c==null || p.EUR_CRM_Answer__c== '')
                            p.EUR_CRM_Answer__c = '0';
                                
                        Double answer = Double.valueOf(p.EUR_CRM_Answer__c);
                    
                        if (condition.equalsIgnorecase('='))
                        {
                            bool = (answer == ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('!='))
                        {
                            bool = (answer != ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<'))
                        {
                            bool = (answer < ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>'))
                        {
                            bool = (answer > ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('<='))
                        {
                            bool = (answer <= ca.EUR_CRM_Base_Currency__c) ? true: false;
                        }
                        else if (condition.equalsIgnorecase('>='))
                        {
                            bool = (answer >= ca.EUR_CRM_Base_Currency__c) ? true: false;
                        } 
                    }
                }
                if(bool){
                    answerWeight = ca.EUR_CRM_Weight__c * volThresholdWeightMapCurr.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                }
                
            }
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updateProsVolPotentialListCurr2.add(pv);
        }
        system.debug('@@@VolCurr' + updateProsVolPotentialListCurr2);
        if (updateProsVolPotentialListCurr2.size() > 0){
            insert updateProsVolPotentialListCurr2;
        }
        system.debug('@@@updateListProsSegImgLevelCurr' + updateProsVolPotentialListCurr2.size());                      
    }
   
    public void calculateTextVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListText = null;
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListText2  = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapVolText = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        
        //ctList = [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
        //          where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Text_Input'];
        //system.debug('ctListDevNameText' + ctList.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapText = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        /*for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            prosSegIdMap.put(eupros.Id, eupros);
        }*/
        
        for (EUR_CRM_Criteria_Threshold__c e: [Select Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c from EUR_CRM_Criteria_Threshold__c
                                                    where EUR_CRM_Criteria_Set__c =: cSetId  and Recordtype.DeveloperName =:'EUR_CRM_Text_Input']){
            ctIds.add(e.Id);
            volThresholdWeightMapText.put(e.Id, e);
        }
        
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListText = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListText2 = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListText = [Select Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName from EUR_CRM_Pros_Volume_Potential__c
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                    and EUR_CRM_Criteria_Threshold__c IN: ctIds // and EUR_CRM_Is_Mass_Update__c = true 
                                    ORDER BY EUR_CRM_Weight__c];   
        
        /*List<EUR_CRM_Criteria_Answer__c> cAnswerListTempTxt = [Select Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c from EUR_CRM_Criteria_Answer__c
                        where EUR_CRM_Criteria_Threshold__c IN: ctIds];  
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempTxt){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapVolText.containsKey(key))?cAnswerMapVolText.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapVolText.put(key,ansList);
        }   */                                      
            
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListText){
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
           // pv.EUR_CRM_Is_Mass_Update__c = true; 
            
            /*Boolean isText = false;
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapVolText.get(p.EUR_CRM_Criteria_Threshold__c)){
                if (volThresholdWeightMapText.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Text_Input')){
                    isText = true;
                }
            }*/
            if (volThresholdWeightMapText.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Text_Input')){
                pv.EUR_CRM_Weight__c = 0;
            }
            updateProsVolPotentialListText2.add(pv);
        }       
        if (updateProsVolPotentialListText2.size() > 0){            
            insert updateProsVolPotentialListText2;
        }
    }
    /*
    public void deleteOldPros(){
        for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
            prosSegIdMap.put(eupros.Id, eupros);
        }
        
        if (isImage){
        List<EUR_CRM_Pros_Image_Level__c> toDeleteProsImageList = new List<EUR_CRM_Pros_Image_Level__c>();
        toDeleteProsImageList = [Select Id, //EUR_CRM_Is_Mass_Update__c, 
                                    EUR_CRM_Pros_Segmentation__c from
                                    EUR_CRM_Pros_Image_Level__c where  EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset() 
                                        //AND EUR_CRM_Is_Mass_Update__c = false
                                        ];
        
            if (toDeleteProsImageList.size() > 0){
                delete toDeleteProsImageList;
            }   
        }   
        
        if (isVol){                     
            List<EUR_CRM_Pros_Volume_Potential__c> toDeleteProsVolList = new List<EUR_CRM_Pros_Volume_Potential__c>();
            toDeleteProsVolList = [Select Id, //EUR_CRM_Is_Mass_Update__c, 
                                    EUR_CRM_Pros_Segmentation__c from EUR_CRM_Pros_Volume_Potential__c 
                                    where EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()// AND EUR_CRM_Is_Mass_Update__c = false
                                    ];
            system.debug('toDeleteProsVolList' + toDeleteProsVolList.size());
            
            if(toDeleteProsVolList.size() > 0){
                delete toDeleteProsVolList;
            }
        }
    }
    */
    /* removed 6/4/14 deletion is already handled by the trigger
    private void deleteObjects(){
        system.debug('++ delete old pros invoke!');
        List<SObject> toDelete = new List<SObject>();
        for(Id i : toDeleteImageIDs){
             toDelete.add(new EUR_CRM_Pros_Image_Level__c(Id = i ));        
        }
        for(Id i : toDeleteVolumeIDs){
             toDelete.add(new EUR_CRM_Pros_Volume_Potential__c(Id = i ));        
        }
        if(toDelete.size() > 0){
            delete toDelete;
        }
        //EUR_CRM_Pros_Volume_Potential__c
    }
    */
    /*public EUR_CRM_Criteria_Set__c csetRec{
        get{
            if(stdCon == null){
                return null;
            }
            return (EUR_CRM_Criteria_Set__c) stdCon.getRecord();
        }
    }*/
}