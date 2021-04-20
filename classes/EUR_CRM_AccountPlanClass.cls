public with sharing class EUR_CRM_AccountPlanClass {
     
        private ApexPages.StandardController standardController{get;set;}
        
        private static Integer PAGE_BREAK = 4;
        public Account acct{get; set;}
        public EUR_CRM_Pros_Segmentation__c prosSeg{get;set;}
        public EUR_CRM_Service_Pack__c serPack {get; set;}
        public List <EUR_CRM_Service_Pack_Item__c> listSerPackitem {get; set;}
        public Map<Integer, List<EUR_CRM_Service_Pack_Item__c>> serPackItemMap {get;set;}
        public List<Schema.FieldSetMember> activationFieldSet{get;set;}
        public List<Schema.FieldSetMember> presenceFieldSet{get;set;}
        public List<Schema.FieldSetMember> visibilityFieldSet{get;set;} 
        public Boolean isPrintPDFEnabled {get;set;}
        public Boolean isE1 {get;set;}
        //public Boolean isBaltics {get;set;}
        public Datetime servicePackLastModifiedDate {get;set;} 
        private static Set<String> printPDFEnbledRecordTypes= new Set<String>{
            'EUR_EE_PROS_Segmentation',
            'EUR_LT_PROS_Segmentation',
            'EUR_LV_PROS_Segmentation',
            'EUR_E1_PROS_Segmentation',
            'EUR_AO_PROS_Segmentation', //Enable PDF button for AO - Task #90
            'EUR_KE_PROS_Segmentation' //Enable PDF button for KE - Task #90
        }; 
        
        //FROM CAP GEMINI: public List <EUR_CRM_Objective__c> listObjectivos{get; set;}
        //FROM CAP GEMINI: public List <EUR_CRM_Objective__c> listObjectivosMarca{get; set;}
        //FROM CAP GEMINI: public List <EUR_CRM_Objective__c> listConsumos{get;set;}
        //FROM CAP GEMINI: public Map <Id, EUR_CRM_Objective__c> mapMarcas {get; set;}
        //FROM CAP GEMINI: public Map <String, Attachment> mapAccoes{get; set;}
        //FROM CAP GEMINI: public List <Attachment> listAtt{get; set;}
        //FROM CAP GEMINI: public Contract con{get; set;}
        
        public EUR_CRM_AccountPlanClass (ApexPages.StandardController standardController){
            //Standard Controller = Pros Segmentation
            this.standardController = standardController;
            
            prosSeg = (EUR_CRM_Pros_Segmentation__c)standardController.getRecord();
            prosSeg = [SELECT id, Name, EUR_CRM_Account__r.Name, Recordtype.DeveloperName,
                                    EUR_CRM_Standard_Account__c, EUR_CRM_Standard_Account__r.Name,
                                    EUR_CRM_Account__c, //EUR_CRM_Affiliate__c,
                                    EUR_CRM_Service_Pack__c, //EUR_CRM_Image_Level__c,                                      
                                    EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,
                                    //EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Name__c,
                                    EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c,
                                    EUR_CRM_Image_Level__r.EUR_CRM_Name__c, 
                                    EUR_CRM_Country_Code__c, EUR_CRM_Outlet_Type__r.EUR_CRM_Name__c,
                                    EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c,
                                    EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c,
                                    LastModifiedDate
                                    FROM EUR_CRM_Pros_Segmentation__c
                                    WHERE id =: prosSeg.id];
            /*//FROM CAPGEMINI                       
            Map <ID, Contract> mapContract = new Map <ID, Contract> ();
            for(Contract contr : [SELECT id, AccountID FROM Contract]){
                    
                    mapContract.put(contr.AccountID, contr);
            }
            */
             
            
            System.debug('Flag - Service Pack ID:' + prosSeg.EUR_CRM_Service_Pack__c);
            System.debug('Flag - Check Pros:' + prosSeg);
            String countryCode = prosSeg.eur_Crm_country_code__c;
            String countryCodeKey = '_'+countryCode.toLowerCase()+'_';
            String defaultKey = '_00_';
            List<Schema.FieldSetMember> defaultActivationFieldSet;
            List<Schema.FieldSetMember> defaultPresenceFieldSet;
            List<Schema.FieldSetMember> defaultVisibilityFieldSet;
             
            for(String key: SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().keySet()){
               
              if(key.contains('activation') && key.contains(countryCodeKey ))
               activationFieldSet =  SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().get(key).getFields();
              if(key.contains('presence')&& key.contains(countryCodeKey  ))
               presenceFieldSet =  SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().get(key).getFields();
              if(key.contains('visibility')&& key.contains(countryCodeKey ))
               visibilityFieldSet =  SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().get(key).getFields();
              
              if(key.contains('activation') && key.contains(defaultKey ))
               defaultActivationFieldSet =  SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().get(key).getFields();
              if(key.contains('presence')&& key.contains(defaultKey ))
               defaultPresenceFieldSet =  SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().get(key).getFields();
              if(key.contains('visibility')&& key.contains(defaultKey ))
               defaultVisibilityFieldSet =  SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().get(key).getFields();
            }

            activationFieldSet = activationFieldSet  != null ? activationFieldSet : defaultActivationFieldSet;
            presenceFieldSet = presenceFieldSet != null ? presenceFieldSet : defaultPresenceFieldSet;
            visibilityFieldSet = visibilityFieldSet != null ? visibilityFieldSet : defaultVisibilityFieldSet;
            
            if(prosSeg.EUR_CRM_Country_Code__c != null && prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c !=null && prosSeg.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c!=null){
                getSerPack();
                if(serPack != null)
                    servicePackLastModifiedDate = initSerivePackLastmodifiedDate(serPack.id);
            }
             
            if(printPDFEnbledRecordTypes.contains(prosSeg.Recordtype.DeveloperName)){ 
                isPrintPDFEnabled = true;
            }
        }
        public String getUserLanguage(){
            return UserInfo.getLanguage();
        }
        public void getSerPack(){
            serPack = null;
            // SERVICE PACK 
            System.debug('Flag - getSerPack - Check Pros:' + prosSeg);
            if (prosSeg != null){
                //Edit 10/15 - Changed source of image level from Image Level Threshold to Account (EU) image level to support Force Iconic.
                //Edit 11/06 - Retained use of Image Level Threshold for PRT
                String imageLevelName = (prosSeg.EUR_CRM_Country_Code__c .equalsIgnoreCase('PRT'))?prosSeg.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c:prosSeg.EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c;
                
                List<EUR_CRM_Service_Pack__c> tempSerPack = [SELECT id, Name, EUR_CRM_Segmentation__c, EUR_CRM_Outlet_Type__c, 
                                                            EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Country__c
                                                            FROM EUR_CRM_Service_Pack__c
                                                            WHERE EUR_CRM_Country_Code__c =: prosSeg.EUR_CRM_Country_Code__c 
                                                            AND  EUR_CRM_Outlet_Type__c=: prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c
                                                            //AND EUR_CRM_Segmentation__c=: prosSeg.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Name__c];
                                                            //AND EUR_CRM_Segmentation__c=: prosSeg.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c
                                                            AND EUR_CRM_Segmentation__c=: imageLevelName
                                                            ];
                                                            
                                                            //WHERE EUR_CRM_Affiliate__c =: prosSeg.EUR_CRM_Affiliate__c
                                                            //AND  EUR_CRM_Outlet_Type__c=: prosSeg.EUR_CRM_Group_Outlet_Type__c
                                                            //AND EUR_CRM_Segmentation__c=: prosSeg.EUR_CRM_Image_Level__c];
                                                            //WHERE id =: prosSeg.EUR_CRM_Service_Pack__c];
                                        
                if(tempSerPack.size()>0){
                    serPack = tempSerPack[0];
                    prosSeg.EUR_CRM_Service_Pack__c = serPack.Id;
                    System.debug('FLAG - Service Pack: ' + serPack);
                    listSerPackitem  = retrieveServicePackItems();                                                        
                    System.debug('FLAG - Service Pack Items: ' + listSerPackitem);
                    
                    prepareSerPackItemPerPage();
                }
            }
        }
        
         /*//FROM CAPGEMINI
        public void getObje(){
                listObjectivosMarca = new List <EUR_CRM_Objective__c> ();
                
                //OBJECTIVOS e CONSUMOS 
                mapMarcas = new Map<Id, EUR_CRM_Objective__c>();
                listObjectivos = new List <EUR_CRM_Objective__c> ();
                listConsumos = new List <EUR_CRM_Objective__c> ();
                for(EUR_CRM_Objective__c obj: [SELECT id, Name, EUR_CRM_Active__c, EUR_CRM_Contract__c, EUR_CRM_Brand__c, 
                                                                        EUR_CRM_Brand__r.EUR_CRM_Brand__c, EUR_CRM_Type_Objective__c, 
                                                                        EUR_CRM_Objective__c, EUR_CRM_Actual__c, EUR_CRM_Actual_Date__c, EUR_CRM_Comment__c,
                                                                        EUR_CRM_Investment_Mkt__c, EUR_CRM_Investment_Sales__c, EUR_CRM_Investment_Total__c,
                                                                        EUR_CRM_Consumption__c, EUR_CRM_Previous_Consumption__c, EUR_CRM_Type_Action__c, EUR_CRM_Brand__r.Name, EUR_CRM_Brand__r.EUR_CRM_Quality_Image_URL__c 
                                                                        FROM EUR_CRM_Objective__c Where EUR_CRM_Contract__c =: con.id]){

                        if(obj.EUR_CRM_Type_Objective__c == 'Consumos por Marca')
                                listConsumos.add(obj);
                        else{
                                listObjectivos.add(obj);
                                mapMarcas.put(obj.EUR_CRM_Brand__c, obj);                   
                        }
                        
                }
                
                // ACCÔES
                List <ID> setAccoes = new List <Id>();
                for(EUR_CRM_Action__c acc : [SELECT id, Name, EUR_CRM_Outlet__c FROM EUR_CRM_Action__c WHERE EUR_CRM_Outlet__c =: prosSeg.EUR_CRM_Account__c]){
                        setAccoes.add(acc.id);
                }

                mapAccoes = new Map <String, Attachment>();
                for(Attachment att : [SELECT id, Name, ParentId, Parent.Name FROM Attachment WHERE ParentID IN : setAccoes]){
                        
                        mapAccoes.put(att.ParentID, att);
                }
                                        
        }
        
       
        public void getFotos(){
                ID accaoID = Apexpages.currentPage().getParameters().get('Categoria');
                listAtt = new List <Attachment>([SELECT ID, ParentID FROM Attachment WHERE ParentID =:accaoID]);
        }
        
        public void getObjectivos(){
                ID objID = Apexpages.currentPage().getParameters().get('idMarca');
                listObjectivosMarca =[SELECT id, Name, EUR_CRM_Active__c, EUR_CRM_Contract__c, EUR_CRM_Brand__c, 
                                                                        EUR_CRM_Brand__r.EUR_CRM_Brand__c, EUR_CRM_Type_Objective__c, 
                                                                        EUR_CRM_Objective__c, EUR_CRM_Actual__c, EUR_CRM_Actual_Date__c, EUR_CRM_Comment__c,
                                                                        EUR_CRM_Investment_Mkt__c, EUR_CRM_Investment_Sales__c, EUR_CRM_Investment_Total__c,
                                                                        EUR_CRM_Consumption__c, EUR_CRM_Previous_Consumption__c, EUR_CRM_Type_Action__c, EUR_CRM_Brand__r.Name, EUR_CRM_Brand__r.EUR_CRM_Quality_Image_URL__c 
                                                                        FROM EUR_CRM_Objective__c WHERE EUR_CRM_Brand__c =: objID];             
        }
        */
        
        public void prepareSerPackItemPerPage(){
            serPackItemMap = new Map<Integer, List<EUR_CRM_Service_Pack_Item__c>>();
            
            List<EUR_CRM_Service_Pack_Item__c> serPackItemPerPage = new List<EUR_CRM_Service_Pack_Item__c>();
            Integer ctr = 0;
            Integer ctrMap = 0;
            
            Boolean pageBreak = false;
            
            for(EUR_CRM_Service_Pack_Item__c sp :listSerPackitem){
                ctr++;
                if(ctr <= PAGE_BREAK){
                    serPackItemPerPage.add(sp);
                    system.debug('***serPackItemPerPage : ' + serPackItemPerPage);
                }
                if(ctr == PAGE_BREAK){
                    ctr = 0;
                    ctrMap++;
                    
                    serPackItemMap.put(ctrMap, serPackItemPerPage);
                    serPackItemPerPage = new List<EUR_CRM_Service_Pack_Item__c>();
                    system.debug('***serPackItemMap : ' + serPackItemMap);
                    system.debug('***serPackItemPerPage2 : ' + serPackItemPerPage);
                }
            }
            
            if(serPackItemPerPage.size() > 0){
                serPackItemMap.put(serPackItemMap.size()+1, serPackItemPerPage);
            }
            
            system.debug('***: ' + serPackItemMap);
        }
        
        public PageReference gotoProsSegmentation(){
            PageReference pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
            pageRef.setRedirect(true);
            
            return pageRef;
        }
        private List <EUR_CRM_Service_Pack_Item__c> retrieveServicePackItems() {
            Set<String> iFields = new Set<String>();
            for(String key: SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().keySet()){
              Schema.FieldSet f = SObjectType.EUR_CRM_Service_Pack_Item__c.FieldSets.getMap().get(key); 
                for(Schema.FieldSetMember fm: f.getFields()){
                    iFields.add(fm.getFieldPath());
                }
            }
            String serPackId = serPack.id;
            String theQuery = 'SELECT EUR_CRM_Sub_family__c, EUR_CRM_Sub_family__r.Name,EUR_CRM_Sub_family__r.EUR_CRM_Brand__c, EUR_CRM_Sub_family__r.EUR_CRM_Brand__r.Name, ' + joinList(iFields, ', ') +  
                          ' FROM EUR_CRM_Service_Pack_Item__c WHERE EUR_CRM_Service_Pack__c = :serPackId order by EUR_CRM_Sub_family__r.Name,EUR_CRM_Sub_family__r.EUR_CRM_Brand__r.Name asc';
            return(List <EUR_CRM_Service_Pack_Item__c>)Database.query(theQuery);       
        }
        private static String joinList(Set<String> theList, String separator) {

        if (theList == null)   { return null; }
        if (separator == null) { separator = ''; }

        String joined = '';
        Boolean firstItem = true;
        for (String item : theList) {
            if(null != item) {
                if(firstItem){ firstItem = false; }
                else { joined += separator; }
                joined += item;
            }
        }
        return joined;
    }
    
    private DateTime initSerivePackLastmodifiedDate(Id servicePackId ){
        List<EUR_CRM_Service_Pack_Item__c > servicePackItems = [select id, lastmodifieddate, EUR_CRM_Service_Pack__r.lastmodifieddate from EUR_CRM_Service_Pack_Item__c where EUR_CRM_Service_Pack__c =: servicePackId order by lastmodifieddate desc];
        if(servicePackItems != null && servicePackItems.size()>0){
            EUR_CRM_Service_Pack_Item__c servicePackItem= servicePackItems.get(0);
            if(servicePackItem.lastmodifieddate > servicePackItem.EUR_CRM_Service_Pack__r.lastmodifieddate)
                return   servicePackItem.lastmodifieddate;
            else
                return   servicePackItem.EUR_CRM_Service_Pack__r.lastmodifieddate;
        }
        return null;
    }

}