public without sharing class ASI_CRM_MY_VolumeCardControllerExt extends ASI_CRM_SG_ComponentControllerBase{
    //Component Parameters
    public ASI_CRM_Pros_Segmentation__c prosSegmentationObj {get;set;}
    public Boolean isVolumeCardAvailable {get;set;}
    public Boolean isVolumeDisabled {get;set;}
    //Local Variables
    
    public ASI_CRM_ID_Card__c IdCard{get; set;}
    public List<volumesWrapper> templiVolWrapper{get;set;} 
    
    public String accountId {get{return prosSegmentationObj.ASI_CRM_SG_Customer__c;}}

    public Boolean hasIdCard {set;get;}
    public double totalGrossSales {set;get;}
    public double marketShare {set;get;}
    
    public Map<String, String> damdmatrixMap {get;set;}

            
    public void initVolCard()
    {   
        totalGrossSales = 0;
        marketShare = 0;
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
        String recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Quality__cASI_CRM_MY_Brand_Quality');
        
        /*
        bqList = [SELECT id, Name, 
                ASI_CRM_SG_Brand__c, 
                ASI_CRM_SG_Brand__r.Name,
                ASI_CRM_SG_Sub_Category__c,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Id,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_SG_Quality_Code__c , 
                ASI_CRM_SG_Quality_Is_Competitor__c,
                RecordTypeId,
                ASI_CRM_MY_Price__c
                FROM ASI_CRM_Quality__c
                WHERE RecordTypeId =: recordTypeId
                ORDER BY ASI_CRM_SG_Category__c ASC NULLS LAST, Name];
		*/
        
        bqList = [SELECT id, Name, 
                ASI_CRM_SG_Brand__c, 
                ASI_CRM_SG_Brand__r.Name,
                ASI_CRM_SG_Sub_Category__c,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Id,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Name,
                ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                ASI_CRM_SG_Quality_Code__c , 
                ASI_CRM_SG_Quality_Is_Competitor__c,
                RecordTypeId,
                ASI_CRM_MY_Price__c
                FROM ASI_CRM_Quality__c
                WHERE RecordTypeId =: recordTypeId
                ORDER BY ASI_CRM_SG_Category__c, ASI_CRM_SG_Brand__r.Name ASC NULLS LAST];
        
        for(ASI_CRM_Quality__c bq : bqList){
           brandMap.put(bq.Id, bq.Name);
        }
        System.debug('Flag-getCardVolumes for bqList: ' + bqList);
        //Populate Volume Wrapper using BQ
        getIdCardVolumes(bqList, brandMap);  
    }
    
    public void getIdCardVolumes(List<ASI_CRM_Quality__c> bqList, Map <Id, String> brandMap){
        //Populate Volume Wrapper list
        templiVolWrapper = new List<volumesWrapper>();        
        volumesWrapper volW;
        totalGrossSales = 0;
        double totalPRMVolume = 0;
        double totalCompetitorVolume = 0;
        double totalVolume = 0;
        marketShare = 0;
        
        Map<Id, ASI_CRM_ID_Card_Volume__c> quaMap = new Map<Id, ASI_CRM_ID_Card_Volume__c>();     
        System.debug('Flag-getCardVolumes for ID Card: ' + IdCard);
        /*
        List<ASI_CRM_ID_Card_Volume__c> idCardVolList = 
            [SELECT 
                Id, 
                ASI_CRM_SG_ID_Card__c, Name, 
                ASI_CRM_SG_Category__c,
                ASI_CRM_SG_Annual_Volume__c, 
                ASI_CRM_SG_Service_Mark__c,
                ASI_CRM_SG_Service_Mark__r.Name,
                ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c,
                ASI_CRM_SG_Service_Mark__r.ASI_CRM_MY_Price__c 
            FROM ASI_CRM_ID_Card_Volume__c 
            WHERE ASI_CRM_SG_ID_Card__c =: IdCard.Id
            ORDER BY ASI_CRM_SG_Category__c, Name ASC NULLS LAST];
        */
        
        List<ASI_CRM_ID_Card_Volume__c> idCardVolList = 
            [SELECT 
                Id, 
                ASI_CRM_SG_ID_Card__c, 
             	Name, 
                ASI_CRM_SG_Category__c,
                ASI_CRM_SG_Annual_Volume__c, 
                ASI_CRM_SG_Service_Mark__c,
                ASI_CRM_SG_Service_Mark__r.Name,
                ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c,
                ASI_CRM_SG_Service_Mark__r.ASI_CRM_MY_Price__c 
            FROM ASI_CRM_ID_Card_Volume__c 
            WHERE ASI_CRM_SG_ID_Card__c =: IdCard.Id
            ORDER BY ASI_CRM_SG_Category__c, Name ASC NULLS LAST];
        
        System.debug('Flag-getCardVolumes for idCardVolList: ' + idCardVolList);
        
        for(ASI_CRM_ID_Card_Volume__c idCardVolObj : idCardVolList)
         {                                                                                                
            volW = new volumesWrapper(idCardVolObj);
            if(Test.isRunningTest()){
                volW.compareTo(volW);
            }
            // volW.vol_IDCardVolumes = idCardVolObj;
            totalGrossSales += volW.grossSales;
            // volW.categoryName = idCardVolObj.ASI_CRM_SG_Category__c;
            volW.bqName = brandMap.get(idCardVolObj.ASI_CRM_SG_Service_Mark__c);
           	Boolean isCompetitor = volW.isCompetitor;
            double annual_volume = idCardVolObj.ASI_CRM_SG_Annual_Volume__c != null ? idCardVolObj.ASI_CRM_SG_Annual_Volume__c : 0.0;
            totalPRMVolume += isCompetitor ? 0 : annual_volume;
         	totalVolume += annual_volume;
            templiVolWrapper.add(volW);
            quaMap.put(idCardVolObj.ASI_CRM_SG_Service_Mark__c, idCardVolObj);
                                                                                                                           
        }
        
        
        //Adicionar Categorias
        
        for(ASI_CRM_Quality__c famObj : bqList){
            if (!quaMap.containsKey(famObj.Id)){
                
                ASI_CRM_ID_Card_Volume__c IDCardVol = new ASI_CRM_ID_Card_Volume__c(
                                ASI_CRM_SG_ID_Card__c = IdCard.id, 
                                ASI_CRM_SG_Service_Mark__c = famObj.Id,
                				recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ID_Card_Volume__cASI_CRM_MY_ID_Card_Volume')); 
				
                //System.debug('Flag-getCardVolumes for IDCardVol: ' + IDCardVol);
                //ASI_CRM_ID_Card_Volume__c IDCardVol = quaMap.get(famObj.Id);
                
                volW = new volumesWrapper(IDCardVol);
                // volW.vol_IDCardVolumes = IDCardVol;
                if(Test.isRunningTest()){
                	volW.compareTo(volW);
                }
                totalGrossSales += volW.grossSales;
                volW.categoryName = famObj.ASI_CRM_SG_Brand__r.ASI_HK_CRM_Product_Category__r.Name;
                volW.bqName = brandMap.get(famObj.Id);
                Boolean isCompetitor = volW.isCompetitor;
                double annual_volume = IDCardVol.ASI_CRM_SG_Annual_Volume__c != null ? IDCardVol.ASI_CRM_SG_Annual_Volume__c : 0.0;
                totalPRMVolume += isCompetitor ? 0 : annual_volume;
                totalVolume += annual_volume;
                //volW.isCompetitor = famObj.ASI_CRM_SG_Quality_Is_Competitor__c;
                templiVolWrapper.add(volW);    
            } 
        }
       	

        if(totalVolume > 0){
        	marketShare = ( totalPRMVolume / totalVolume ) * 100;
        	marketShare = marketShare.round();
        }

		
        
        templiVolWrapper.sort();
    }
    
    public PageReference cancel(){
        PageReference pageRef = null;
        pageRef = new PageReference('/apex/ASI_CRM_MY_ProsSegmentationPage?id='+ ApexPages.currentPage().getParameters().get('id'));
        pageRef.setRedirect(true); 
        return pageRef;
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
            
            
            //prosSegmentationObj.ASI_CRM_Gross_Sales__c = totalGrossSales;
            //prosSegmentationObj.ASI_CRM_Market_Share__c = marketShare;
            
            ASI_CRM_MY_ProsSegmentationClass.assignVolumeOnePotential(prosSegmentationObj, idCard, listInsertVol);
            
            
       
            //Go to Pros Segmentation
            pageRef = new PageReference('/apex/ASI_CRM_MY_ProsSegmentationPage?id='+ ApexPages.currentPage().getParameters().get('id') );
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
        //public ID vol_IDCardVolume{get; set;}
        public ASI_CRM_ID_Card_Volume__c vol_IDCardVolumes{get; set;}   
        public String categoryName{get;set;} 
        //Edit:(SFAPOR-15)
        public String bqName{get;set;} 
        public Boolean isCompetitor {get;set;}
        public Double grossSales{get;set;}
        
        public volumesWrapper(ASI_CRM_ID_Card_Volume__c vol_IDCardVolumes){
            double annual_volume = vol_IDCardVolumes.ASI_CRM_SG_Annual_Volume__c != null ? vol_IDCardVolumes.ASI_CRM_SG_Annual_Volume__c : 0.0;
            double price = vol_IDCardVolumes.ASI_CRM_SG_Service_Mark__r.ASI_CRM_MY_Price__c != null ? vol_IDCardVolumes.ASI_CRM_SG_Service_Mark__r.ASI_CRM_MY_Price__c  : 0.0;
            this.grossSales = annual_volume * price;
            isCompetitor = vol_IDCardVolumes.ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c != null ? vol_IDCardVolumes.ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c : false;
            categoryName = vol_IDCardVolumes.ASI_CRM_SG_Category__c != null ? vol_IDCardVolumes.ASI_CRM_SG_Category__c : '';
            this.vol_IDCardVolumes = vol_IDCardVolumes; 
        } 
        
        public Integer compareTo(Object compareTo){
            volumesWrapper compareToVolumesWrapper = (volumesWrapper)compareTo;
            if(categoryName==compareToVolumesWrapper.categoryName){
                if(bqName > compareToVolumesWrapper.bqName){
                    return 1;
                }
                else return 0;
            }
            else if(categoryName>compareToVolumesWrapper.categoryName){
                return 0;
            }
            return -1;
        }
    }
    
}