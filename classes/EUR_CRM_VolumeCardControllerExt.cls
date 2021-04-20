/*
* Edit 11/11: Changed order of Brands for House Pour selection (SFAPOR-15)
*/
public with sharing class EUR_CRM_VolumeCardControllerExt {

    //Component Attribute
    public String accountId{get;set;}
    public String returnValue{get;set;}
    
    //Variables
    public EUR_CRM_ID_Card__c IdCard{get; set;}
    public Map <String, List <SelectOption>> mapCategorias{get;set;}{mapCategorias= new Map <String, List <SelectOption>>();}
    public List <String> listTabs{get;set;}
    //FROM CAP GEMINI: public List <perguntasWrapper> listPerguntasTab{get;set;}
    public Map <String, volumesWrapper> mapVolWrapper{get;set;}{mapVolWrapper= new Map <String, volumesWrapper>();}
    public Map <ID, EUR_CRM_Quality__c> mapMarcas{get;set;} 
    public Integer mapMarcasSize{set;}
    public Map <String, EUR_CRM_Category__c> mapCategory{get;set;}{mapCategory = new Map<String, EUR_CRM_Category__c>();}
    public String dialogTitle{get;set;}
    public String tab{get;set;}
    public Boolean modoDetail{get;set;}
    public Boolean hasIdCard{get;set;}
    
    public List <EUR_CRM_Quality__c> listMarcasSub = new List <EUR_CRM_Quality__c>();
    public Map <String, EUR_CRM_ID_Card_Volume__c> mapVolumes{get;set;} {mapVolumes=new Map <String, EUR_CRM_ID_Card_Volume__c>();}
    
    public String catId{get;set;}
    public String cat{get;set;}
    public String cla{get;set;}
    
    public boolean saveComplete{get;set;}{saveComplete=false;}
    
    public boolean displayPopup{get;set;}{displayPopup=false;}
    
    //Edit: (SFAPOR-15)
    public List<volumesWrapper> listVolWrapper{get{
        List<volumesWrapper> liVolWrapper = mapVolWrapper.values();
        liVolWrapper.sort();
        return liVolWrapper;
    }}

    public Set<Id> trackProductsToDelete = new Set<Id>();
    public List<EUR_CRM_PROS_Vol_Tracker_Product__c> listProsVolProds = new List<EUR_CRM_PROS_Vol_Tracker_Product__c>();
    public Map<String,List<EUR_CRM_PROS_Vol_Tracker_Product__c>> mapProsVolProds = new Map<String,List<EUR_CRM_PROS_Vol_Tracker_Product__c>>();

    public List<ProductWrapper> productTrackerWrapList {get;set;}
    
    public boolean isPRT = true;
    public EUR_CRM_VolumeCardControllerExt(ApexPages.StandardController standardController){  
            
        EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_Pros_Segmentation__c)standardController.getRecord();
        
        if(prosSegmentation.EUR_CRM_Account__c != null){
            isPRT = false;
        }
        //accountId = prosSegmentation.EUR_CRM_Account__c;
        accountId = prosSegmentation.EUR_CRM_Standard_Account__c;
        returnValue = prosSegmentation.Id;
        
        System.debug('Flag - INIT VOLUME CARD 1:' + accountId + '|' + returnValue);
     }
     
     public EUR_CRM_VolumeCardControllerExt(){  
            
        //EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_Pros_Segmentation__c)standardController.getRecord();
        //accountId = prosSegmentation.EUR_CRM_Account__c;
        //returnValue = prosSegmentation.Id;
        
        System.debug('Flag - Volume Card Component Constructor:' + accountId + '|' + returnValue);
     }
    
    public void initVolCard()
    {   if(isPRT){
        List <EUR_CRM_ID_Card__c> listIDCard = new List <EUR_CRM_ID_Card__c>([SELECT Id, Name, //EUR_CRM_Outlet_Type__c,
                                                                         EUR_CRM_Outlet__c, 
                                                                        EUR_CRM_Total_Super_Ultra_Brands__c
                                                                        //EUR_CRM_Total_Annual_Volume__c
                                                                        FROM EUR_CRM_ID_Card__c 
                                                                        WHERE EUR_CRM_Outlet__c =: accountId  
                                                                        LIMIT 1]);
        //FROM CAP GEMINI: listPerguntasTab = new List <perguntasWrapper>();
        System.debug('Flag - INIT VOLUME CARD 2:' + accountId + '|' + listIDCard);
        modoDetail = true;
        //System.debug('INIT EUR_CRM_IDCardSheetController: ' + listIDCard);
        
        if(listIDCard.size() == 0)
            criarIdCard();                
        else{
                IdCard = listIDCard[0];
                hasIdCard = true;
                System.debug('Flag ID CARD: ' + IdCard);
                getData(IdCard);
        }
    }
    }
    
    public void setAccountId(String account)
    {
       accountId = account;
    }
    
    public String getAccountId()
    {
       return accountId;
    }
    
    public Integer getMapMarcasSize(){
        if (mapMarcas== null)
            return 0;
        else
            return mapMarcas.size();
    }
    
    public void getData(EUR_CRM_ID_Card__c IdCard){
            // TABELA DE VOLUMES ---------------------------------------------------
            //Creates Category Map, and invokes initialization of Volume Wrapper Map
            System.debug('Flag On Get Data:' + IdCard);
            //Query às Famílias de Produtos
            mapCategorias = new Map <String, List <SelectOption>>();
            List <SelectOption> listOptions;
            listMarcasSub = ([SELECT id, Name, 
                            EUR_CRM_Brand__c, 
                            EUR_CRM_Sub_Category__c,
                            EUR_CRM_Brand__r.EUR_CRM_Category__r.Id,
                            EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                            EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c,
                            EUR_CRM_Quality_Code__c , EUR_CRM_Quality_Is_Competitor__c,
                            EUR_CRM_House_Pour__c
                            FROM EUR_CRM_Quality__c
                            WHERE RecordType.Name LIKE 'EUR_PRT%'
                            AND EUR_CRM_House_Pour__c = true
                            ORDER BY EUR_CRM_Quality_Is_Competitor__c, Name]);
             
             System.debug('flag - Brand Sub:' + listMarcasSub);
            
            //Criar Mapa com Categorias
            for(EUR_CRM_Quality__c mar : listMarcasSub){
                    if(mar.EUR_CRM_Brand__c == null){
                        listOptions = new List <SelectOption>();
                        listOptions.add(new SelectOption('','-None-'));
                        mapCategorias.put(mar.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id, listOptions);
                    }
            }       
            
            //Adicionar listOptions de Marcas ao Mapa de Categorias
            for(EUR_CRM_Quality__c sub : listMarcasSub){
                    String key = sub.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id;
                    if(sub.EUR_CRM_Brand__c != null){
                        listOptions = (mapCategorias.containsKey(key))?mapCategorias.get(key):new List <SelectOption>();
                        listOptions.add(new SelectOption(sub.id, sub.Name));
                        mapCategorias.put(key, listOptions);
                    }
            }
            
            getIDCardVolumes();
                                                                                                                    
    }

    public void getIdCardVolumes(){
        //Criar Mapa com Categorias a serem mostradas na tabela e valores
        //mapVolWrapper= new Map <String,volumesWrapper>();
        volumesWrapper volW;
        //EUR_CRM_ID_Card_Volume__c IDCardVol;
        // Query ID_Card_Volumes
        System.debug('Flag-getCardVolumes for ID Card: ' + IdCard);
        for(EUR_CRM_ID_Card_Volume__c idCardVolObj : [SELECT Id, EUR_CRM_ID_Card__c, Name, 
                                                       EUR_CRM_Category__c, 
                                                       EUR_CRM_Category__r.Name,
                                                       EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c,
                                                       EUR_CRM_Annual_Volume__c, 
                                                       EUR_CRM_Dose_Service__c, 
                                                       EUR_CRM_Service_Mark__c, 
                                                       EUR_CRM_No_Premium_Brands__c,
                                                       EUR_CRM_No_SuperPremium_Brands__c,
                                                       EUR_CRM_No_UltraPremium_Brands__c,
                                                       EUR_CRM_Service_Mark__r.EUR_CRM_Quality_Is_Competitor__c,
                                                       EUR_CRM_Service_Mark__r.Name
                                                       FROM EUR_CRM_ID_Card_Volume__c 
                                                       WHERE EUR_CRM_ID_Card__c =: IdCard.Id])
            {                                                                                                 
                mapVolumes.put(idCardVolObj.EUR_CRM_Category__c, idCardVolObj);
                
                volW = new volumesWrapper();
                        volW.vol_IDCardVolumes = idCardVolObj;
                        volW.vol_listMarcas = mapCategorias.get(idCardVolObj.EUR_CRM_Category__c);
                        volW.vol_nuSuperPrem = 0;
                        volW.categoryName = idCardVolObj.EUR_CRM_Category__r.Name;
                        volW.isCompetitor = idCardVolObj.EUR_CRM_Service_Mark__r.EUR_CRM_Quality_Is_Competitor__c;
                        volW.categoryContributiveMargin = (idCardVolObj.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c==null)?0:idCardVolObj.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c;
                        volW.bqName = idCardVolObj.EUR_CRM_Service_Mark__r.Name;
                        System.debug('########################################################LISTA1-ID CARD'+ volW.vol_IDCardVolumes);  
                        System.debug('########################################################LISTA1'+ volW.vol_listMarcas);     
                mapVolWrapper.put(idCardVolObj.EUR_CRM_Category__c, volW);                                                                                                  
        }
        
        //Adicionar Categorias
        for(EUR_CRM_Quality__c famObj : listMarcasSub){
                if (!(mapVolWrapper.containsKey(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id))){
                    volW = new volumesWrapper();
                    EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = IdCard.id, 
                                                                EUR_CRM_Category__c = famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id,
                                                                EUR_CRM_Service_Mark__c = null,
                                                                EUR_CRM_No_Premium_Brands__c=0,
                                                                EUR_CRM_No_SuperPremium_Brands__c=0,
                                                                EUR_CRM_No_UltraPremium_Brands__c=0);        
                    volW.vol_IDCardVolumes = IDCardVol;
                    volW.categoryName = famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
                    volW.vol_listMarcas = mapCategorias.get(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id);
                    volW.isCompetitor = famObj.EUR_CRM_Quality_Is_Competitor__c;
                    volW.categoryContributiveMargin = (famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c==null)?0:famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c;
                    volW.bqName = famObj.Name;
                    mapVolWrapper.put(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id,volW);
                    mapVolumes.put(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id, IDCardVol);
                    System.debug('########################################################LISTA2-ID CARD'+ volW.vol_IDCardVolumes); 
                    System.debug('########################################################LISTA2'+ volW.vol_listMarcas);     
                }
        }
        System.debug('Flag - Map Vol Wrapper: '+mapVolWrapper);
        System.debug('flag - Map categories: ' + mapCategorias);
    }

    //Abri caixa de diálogo
    public void getMarcasPremium(){
        System.debug('#########################ENTROU');
        System.debug('Flag - ID Card Volumes Map:' + mapVolumes);
        System.debug('Flag - ID:' + IdCard);
        catId = Apexpages.currentPage().getParameters().get('CategoriaId');
        cat = Apexpages.currentPage().getParameters().get('Categoria');
        cla = Apexpages.currentPage().getParameters().get('Classificacao');
        dialogTitle =  cat + ' - ' + cla; 
            
            //mapMarcas = new Map <ID, EUR_CRM_Quality__c>(); 
            mapMarcas = new Map<Id, EUR_CRM_Quality__c>([SELECT Id, Name,
                                    EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                                    EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                    EUR_CRM_Sub_Category__c,
                                    EUR_CRM_Brand__r.Id, EUR_CRM_Quality_Is_Competitor__c,
                                    EUR_CRM_House_Pour__c 
                                    FROM EUR_CRM_Quality__c
                                    WHERE EUR_CRM_Sub_Category__c=:cla
                                    AND EUR_CRM_House_Pour__c = true
                                    AND EUR_CRM_Brand__r.EUR_CRM_Category__c=:catId]);

            System.debug('Quality Map - Sub Category:' + mapMarcas);   

        Set<Id> bQProductIds = new Set<Id>();
        for(EUR_CRM_PROS_Vol_Tracker_Product__c trackProd : [SELECT Id, EUR_CRM_Brand_Quality__c, EUR_CRM_ID_Card_Volume__c FROM EUR_CRM_PROS_Vol_Tracker_Product__c WHERE EUR_CRM_ID_Card_Volume__r.EUR_CRM_ID_Card__c =:IdCard.Id]){
            bQProductIds.add(trackProd.EUR_CRM_Brand_Quality__c);
        }

        productTrackerWrapList = new List<ProductWrapper>();
        for(EUR_CRM_Quality__c bQuality : mapMarcas.values()){
            Boolean isProduct = false;
            if(bQProductIds.contains(bQuality.Id)){
                isProduct = true;
            }
            productTrackerWrapList.add(new ProductWrapper(isProduct, bQuality));
        }

        System.debug('##TEST WRAPPER: '+productTrackerWrapList);
        

    }
    
            // Salvar marcas
    public PageReference saveMarcasPremium(){
        PageReference pageRef = null;
        System.Savepoint pSavepoint = Database.setSavepoint();
        try {
                System.debug('#################################'+cat);
                System.debug('Flag - On Save Marcas Map Volumes:' + mapVolumes +'#####'+ mapVolumes.containsKey(catId)); 
                System.debug('Flag - On Save Categorias Map Volumes:' + mapCategorias + '####'+ IdCard);
                if (IdCard==null){
                    System.debug('Flag - ID Card is null, reset');
                    initVolCard();
                }
                System.debug('Flag - SaveMarcasPremium Checker:' + IdCard + '|' + catId);
                String sss = Apexpages.currentPage().getParameters().get('Str');
       
            List <ID> listMarcasChecked = new List <ID>();
            if(sss!=null && sss.length()>0){
                    sss = sss.removeEnd(',');
                    
                    if (sss.contains(','))
                            listMarcasChecked = sss.split(',');
                else
                    listMarcasChecked.add(sss);
             }

            EUR_CRM_ID_Card_Volume__c IDCardV;
            if(mapVolumes.containsKey(catId)){
                    IDCardV = mapVolumes.get(catId);
                    System.debug('Flag IDCardV 1:' +  IDCardV);
            }
            else{
                    IDCardV = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = IdCard.id, 
                                                                                            EUR_CRM_Category__c = catId,
                                                        EUR_CRM_No_Premium_Brands__c=0,
                                                        EUR_CRM_No_SuperPremium_Brands__c=0,
                                                        EUR_CRM_No_UltraPremium_Brands__c=0);
                    System.debug('Flag IDCardV 2:' +  IDCardV);
            }
            
            //System.debug('IDCardV: ' + IDCardV);
            IDCardV.EUR_CRM_No_Premium_Brands__c = (IDCardV.EUR_CRM_No_Premium_Brands__c==null)?0:IDCardV.EUR_CRM_No_Premium_Brands__c;
            IDCardV.EUR_CRM_No_SuperPremium_Brands__c = (IDCardV.EUR_CRM_No_SuperPremium_Brands__c==null)?0:IDCardV.EUR_CRM_No_SuperPremium_Brands__c;
            IDCardV.EUR_CRM_No_UltraPremium_Brands__c = (IDCardV.EUR_CRM_No_UltraPremium_Brands__c==null)?0:IDCardV.EUR_CRM_No_UltraPremium_Brands__c;
            
            System.debug('IDCardV: ' + IDCardV);
            
            if (cla.equalsIgnoreCase('Premium'))
            {IDCardV.EUR_CRM_No_Premium_Brands__c = listMarcasChecked.size();}
            else if (cla.equalsIgnoreCase('Super Premium'))
            {IDCardV.EUR_CRM_No_SuperPremium_Brands__c = listMarcasChecked.size();}
            else if (cla.equalsIgnoreCase('Ultra Premium'))
            {IDCardV.EUR_CRM_No_UltraPremium_Brands__c = listMarcasChecked.size();}
            
            //System.debug('Flag - Upsert ID Card Volume:' + IDCardV);       
            //Database.upsert(IDCardV);
            
            //pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id') );
            //pageRef.setRedirect(true);

            System.debug('$$VOL PROS: '+listMarcasChecked);
            //Create PROS Vol Tracker Product
            String keyString = IDCardV.Id+':'+cla;
            System.debug('$$KEY STRING: '+keyString);
            Integer ctr = 0;
            for(Id key : listMarcasChecked){

                EUR_CRM_PROS_Vol_Tracker_Product__c prosVolProd = new EUR_CRM_PROS_Vol_Tracker_Product__c();
                prosvolProd.EUR_CRM_Brand_Quality__c = key;
                prosvolProd.EUR_CRM_ID_Card_Volume__c = IDCardV.Id;

                //listProsVolProds.add(prosvolProd);
                if (mapProsVolProds.containsKey(keyString)){
                    if(ctr == 0){
                        mapProsVolProds.get(keyString).clear();
                    }
                    mapProsVolProds.get(keyString).add(prosvolProd);
                } else {
                    mapProsVolProds.put(keyString, new  List<EUR_CRM_PROS_Vol_Tracker_Product__c> {prosvolProd});
                }
                ctr++;
            }
            //System.debug('$$VOL PROS PRODUCTS: '+listProsVolProds);
            System.debug('$$VOL PROS PRODUCTS: '+mapProsVolProds);
            
            System.debug('Flag - On Save Marcas ID Card Volume:' + IDCardV);
        }
        catch(Exception e){
            System.debug('Upsert Error: ' + e);
            pageRef= null;
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
            
        return pageRef;               
    }
    
    // SALVAR ID CARD-----------------------------------------
    public PageReference saveP(){
        //Salvar Volumes
        System.debug('Flag - On SaveP');
        PageReference pageRef= null;
        System.Savepoint pSavepoint = Database.setSavepoint();

        try{
            List <EUR_CRM_ID_Card_Volume__c> listInsertVol = new List <EUR_CRM_ID_Card_Volume__c>();
            
            if (mapVolWrapper == null){
                    System.debug('Flag - Map Volume Wrapper is null, reset it');
                    initVolCard();
            }
            
            System.debug('Flag - OnSaveP mapVolumeWrapper:' + mapVolWrapper);
            for(volumesWrapper volW : mapVolWrapper.values())
            {       
                EUR_CRM_ID_Card_Volume__c IDVol = volW.vol_IDCardVolumes;
                //if(IDVol.EUR_CRM_Service_Mark__c != null || IDVol.EUR_CRM_Dose_Service__c != null || IDVol.EUR_CRM_Annual_Volume__c != null){               
                listInsertVol.add(IDVol);               
                //}
            }
            
            System.debug('Flag - On SaveP Upsert ID Card Volumes: ' + listInsertVol);
            upsert listInsertVol;

            //INSERT Pros Vol Tracker Products
            System.debug('%%SAVE: ' + mapProsVolProds);
            if(mapProsVolProds.size() > 0){
                List<EUR_CRM_PROS_Vol_Tracker_Product__c> insertTrackProducts = new List<EUR_CRM_PROS_Vol_Tracker_Product__c>();
                List<EUR_CRM_PROS_Vol_Tracker_Product__c> deleteTrackProducts = new List<EUR_CRM_PROS_Vol_Tracker_Product__c>();
                for(String key : mapProsVolProds.keyset()){
                    for(EUR_CRM_PROS_Vol_Tracker_Product__c trackProd : mapProsVolProds.get(key)){
                        insertTrackProducts.add(trackProd);
                        trackProductsToDelete.add(trackProd.EUR_CRM_ID_Card_Volume__c);
                    }
                }

                if(trackProductsToDelete.size()>0){
                    for(EUR_CRM_PROS_Vol_Tracker_Product__c delTrack : [SELECT Id FROM EUR_CRM_PROS_Vol_Tracker_Product__c WHERE EUR_CRM_ID_Card_Volume__c IN: trackProductsToDelete]){
                        deleteTrackProducts.add(delTrack);
                    }
                    if(deleteTrackProducts.size() > 0){
                        delete deleteTrackProducts;
                    }
                }

                upsert insertTrackProducts;
            }

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
    
    public void criarIdCard(){
        //EUR_CRM_ID_Card__c IdCardSheetNew = createNewIdCardSheet();
        System.debug('Flag - Create new ID Card');
        EUR_CRM_ID_Card__c IdCardNew = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = accountId);  
        insert IdCardNew;
        hasIDCard = true;
        IDCard = IdCardNew;
        getData(IDCard);
    }

   /* public void saveIDCardSheet(){
        try{                       
            System.debug('FLAG ID Card Sheet: ' + IdCard);
            upsert IdCard;
        }
        catch(Exception e){
            System.debug('saveIDCardSheet Error:' + e);
        }
    }
    */

    public class ProductWrapper{

        public Boolean isChecked {get;set;}
        public EUR_CRM_Quality__c brandQuality {get;set;}
        
        public ProductWrapper(Boolean isChecked, EUR_CRM_Quality__c brandQuality){
            this.isChecked = isChecked;
            this.brandQuality = brandQuality;
        }
    }


    public class volumesWrapper implements Comparable {
        public ID vol_IDCardVolume{get; set;}
        public EUR_CRM_ID_Card_Volume__c vol_IDCardVolumes{get; set;}
        public String vol_Categoria{get; set;}
        public Integer vol_volumesAnuais{get; set;}
        public Integer vol_doseServico{get; set;}
        public String vol_marcaServico{get; set;}
        public Integer vol_nuPrem{get{return vol_nuPrem == null?0:vol_nuPrem;} set;}
        public Integer vol_nuSuperPrem{get{return vol_nuSuperPrem == null?0:vol_nuSuperPrem;} set;}
        public Integer vol_nuUltraPrem{get{return vol_nuUltraPrem == null?0:vol_nuUltraPrem;} set;}
        public List <SelectOption> vol_listMarcas{get; set;}     
        public String categoryName{get;set;} 
        //Edit:(SFAPOR-15)
        public String bqName{get;set;}
        public Boolean isCompetitor {get;set;}
        public Decimal categoryContributiveMargin{get;set;} 


        
        public Integer compareTo(Object compareTo){
            volumesWrapper compareToVolumesWrapper = (volumesWrapper) compareTo;
            if (categoryContributiveMargin>compareToVolumesWrapper.categoryContributiveMargin){return -1;}
            else if(categoryContributiveMargin==compareToVolumesWrapper.categoryContributiveMargin){
                if(categoryName==compareToVolumesWrapper.categoryName){return 0;}
                else if(categoryName>compareToVolumesWrapper.categoryName){return 1;}
                return -1;
            }
            return 1;
        }
    }
    /*//FROM CAP GEMINI
    public class perguntasWrapper{ 
            public Id per_IdPergunta{get; set;}
            public String per_pergunta{get; set;}
            public String per_tipoResposta{get; set;}
            public String per_resposta{get; set;}
            public String per_perguntaComplementar{get; set;}
            public String per_respostaComplementar{get; set;}
            public String per_grupoPergunta {get; set;}     
            public List <SelectOption> per_listRespostas{get; set;}
    }

    public class marPremiumWrapper{
            public Boolean mar_checked{get; set;}
            //public EUR_CRM_Sub_Category__c mar_record{get; set;}
            public Id mar_IDSubFamilia{get; set;}
    }
    */
}