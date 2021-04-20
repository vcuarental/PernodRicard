public without sharing class ASI_CRM_VolumeCardControllerExt extends ASI_CRM_SG_ComponentControllerBase{
    //Component Parameters
    public ASI_CRM_Pros_Segmentation__c prosSegmentationObj {get;set;}
    public Boolean isVolumeCardAvailable {get;set;}
    public Boolean isVolumeDisabled {get;set;}
    //Local Variables
    
    public ASI_CRM_ID_Card__c IdCard{get; set;}
    public List<volumesWrapper> templiVolWrapper{get;set;} 
    
    public String accountId {get{return prosSegmentationObj.ASI_CRM_SG_Customer__c;}}

    public Boolean hasIdCard {set;get;}
            
    public void initVolCard()
    {   
        List <ASI_CRM_ID_Card__c> listIDCard = new List <ASI_CRM_ID_Card__c>(
                    [SELECT Id, Name, //ASI_CRM_Outlet_Type__c,
                    ASI_CRM_SG_Outlet__c, ASI_CRM_SG_Total_Annual_Volume__c,
                    ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c
                    FROM ASI_CRM_ID_Card__c 
                    WHERE ASI_CRM_SG_Outlet__c =: accountId  
                    LIMIT 1]);
        //FROM CAP GEMINI: listPerguntasTab = new List <perguntasWrapper>();
        System.debug('Flag - INIT VOLUME CARD 2:' + accountId + '|' + listIDCard);
        //System.debug('INIT ASI_CRM_IDCardSheetController: ' + listIDCard);
        if(listIDCard.size() == 0)
            criarIdCard();                
        else{
            IdCard = listIDCard[0];
            hasIdCard = true;
            System.debug('Flag ID CARD: ' + IdCard);
            getData(IdCard);
        }
    }
    
    public void criarIdCard(){
        System.debug('Flag - Create new ID Card');
        ASI_CRM_ID_Card__c IdCardNew = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = accountId);  
        insert IdCardNew;
        hasIDCard = true;
        IDCard = IdCardNew;
        getData(IDCard);
    }

    
    public void getData(ASI_CRM_ID_Card__c IdCard){
        //Query Brand-Quality
        List <ASI_CRM_Quality__c> bqList= new List <ASI_CRM_Quality__c>(); 
        Map <Id, String> brandMap = new Map<Id, String>();

        bqList = [SELECT id, Name, 
                ASI_CRM_SG_Brand__c, ASI_CRM_SG_Brand__r.Name,
                ASI_CRM_SG_Sub_Category__c,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Id,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_SG_Quality_Code__c , ASI_CRM_SG_Quality_Is_Competitor__c
                FROM ASI_CRM_Quality__c
                ORDER BY ASI_CRM_SG_Category__c ASC NULLS LAST, Name];
        for(ASI_CRM_Quality__c bq : bqList){
           brandMap.put(bq.Id, bq.Name);
        }
        //Populate Volume Wrapper using BQ
        getIdCardVolumes(bqList, brandMap);  
    }
    
    public void getIdCardVolumes(List<ASI_CRM_Quality__c> bqList, Map <Id, String> brandMap){
        //Populate Volume Wrapper list
        templiVolWrapper = new List<volumesWrapper>();        
        volumesWrapper volW;
        Map<Id, ASI_CRM_ID_Card_Volume__c> quaMap = new Map<Id, ASI_CRM_ID_Card_Volume__c>();     
        System.debug('Flag-getCardVolumes for ID Card: ' + IdCard);
        for(ASI_CRM_ID_Card_Volume__c idCardVolObj : [SELECT Id, ASI_CRM_SG_ID_Card__c, Name, 
                                            ASI_CRM_SG_Category__c,
                                            ASI_CRM_SG_Annual_Volume__c, ASI_CRM_SG_Service_Mark__c,
                                            ASI_CRM_SG_Service_Mark__r.Name,
                                            ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c
                                            FROM ASI_CRM_ID_Card_Volume__c 
                                            WHERE ASI_CRM_SG_ID_Card__c =: IdCard.Id
                                            ORDER BY ASI_CRM_SG_Category__c ASC NULLS LAST])
         {                                                                                                
            volW = new volumesWrapper();
            volW.vol_IDCardVolumes = idCardVolObj;
            volW.categoryName = idCardVolObj.ASI_CRM_SG_Category__c;
            volW.bqName = brandMap.get(idCardVolObj.ASI_CRM_SG_Service_Mark__c);
            volW.isCompetitor = idCardVolObj.ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c;
        
            templiVolWrapper.add(volW);
            quaMap.put(idCardVolObj.ASI_CRM_SG_Service_Mark__c, idCardVolObj);
                                                                                                                           
        }
        
        //Adicionar Categorias
        for(ASI_CRM_Quality__c famObj : bqList){
            if (!quaMap.containsKey(famObj.Id)){
                volW = new volumesWrapper();
                ASI_CRM_ID_Card_Volume__c IDCardVol = new ASI_CRM_ID_Card_Volume__c(
                                ASI_CRM_SG_ID_Card__c = IdCard.id, 
                                //ASI_CRM_SG_Category__c = famObj.ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Id,
                                ASI_CRM_SG_Service_Mark__c = famObj.Id);        
                volW.vol_IDCardVolumes = IDCardVol;
                volW.categoryName = famObj.ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                volW.bqName = brandMap.get(famObj.Id);
                volW.isCompetitor = famObj.ASI_CRM_SG_Quality_Is_Competitor__c;
                templiVolWrapper.add(volW);    
            } 
        }
        
        templiVolWrapper.sort();
    }   

    // SALVAR ID CARD-----------------------------------------
    public PageReference saveP(){
        //Salvar Volumes
        System.debug('Flag - On SaveP');
        PageReference pageRef= null;
        System.Savepoint pSavepoint = Database.setSavepoint();

        try{
            List <ASI_CRM_ID_Card_Volume__c> listInsertVol = new List <ASI_CRM_ID_Card_Volume__c>();
            
            if (templiVolWrapper == null){
                System.debug('Flag - Map Volume Wrapper is null, reset it');
                initVolCard();
            }
           
            System.debug('Flag - OnSaveP tempLi:' + templiVolWrapper);
            for(volumesWrapper volW : templiVolWrapper)
            {       
                ASI_CRM_ID_Card_Volume__c IDVol = volW.vol_IDCardVolumes;
                listInsertVol.add(IDVol);               
            }
            
            System.debug('Flag - On SaveP Upsert ID Card Volumes: ' + listInsertVol);
            upsert listInsertVol;
            //Go to Pros Segmentation
            pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id') );
            pageRef.setRedirect(true);
        }
        catch(Exception e){
            System.debug('Upsert Error: ' + e);
            pageRef = null;
            Database.rollback(pSavepoint);      
                    String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
                {
                    String s = e.getDmlMessage(0);
                    strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                }                   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
        }
        
        System.debug('FLAG On SaveP - Page Reference:' + pageRef);
        return pageRef;
    }

    
    public class volumesWrapper implements Comparable{
        public ID vol_IDCardVolume{get; set;}
        public ASI_CRM_ID_Card_Volume__c vol_IDCardVolumes{get; set;}   
        public String categoryName{get;set;} 
        //Edit:(SFAPOR-15)
        public String bqName{get;set;}
        public Boolean isCompetitor {get;set;}
        
        public Integer compareTo(Object compareTo){
            volumesWrapper compareToVolumesWrapper = (volumesWrapper)compareTo;
            if(categoryName==compareToVolumesWrapper.categoryName){
                if(bqName > compareToVolumesWrapper.bqName){
                    return 1;
                }
                else return 0;
                /*if(isCompetitor == false) {return 0;}
                else {return 1;}
                return 0;*/
            }
            else if(categoryName>compareToVolumesWrapper.categoryName){
                return 0;
            }
            return -1;
        }
    }
    
}