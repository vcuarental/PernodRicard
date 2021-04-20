public with sharing class EUR_DOC_DocServerController {
    
        
    static Integer PAGE_SIZE = 15;
    static Integer totalItemCount = 0;
    static String countryCode;
    static boolean bSOActive = checkIfUserHasSO();

    static List<String> IN_ON = null;
    static List<String> IN_OFF = null;
    static List<String> IN_DISTRIB = null;
    static List<String> IN_OTHER = null;

    static Map<String, String> mapPrefix = null;

    static Map<String, String> mapTaxonomyChainField = new MAP<String,String>(loadTaxonomyChainConfig());
    

    public class Filters {
        public DateTime timestamp {get;set;}
        public Date earlierDate { get;set; }
        public Date laterDate { get;set; }
        public String account { get;set; }
        public String user { get;set; }
        public String taxonomychain {get;set;}
        public String taxonomy {get;set;}
        public String territory {get;set;}
        public String region {get;set;}
        public boolean epicenter {get;set;}
        public String module { get;set; }
        public String posm { get;set; }
        public String opcode { get;set; }
        public String op { get;set; }
        public boolean isOnTrade { get;set; }
        public boolean isOffTrade { get;set; }
        public boolean isDistributor { get;set; }
        public boolean isOther { get;set; }
        public String b { get;set; }
        public String bq { get;set; }
        public String bqs { get;set; }
        public String sku { get;set; }
        public String toolkit { get;set; }
        public String bsbq { get;set; }
    }

    @AuraEnabled(Cacheable=true)
    public static List<EUR_DOC_DocServerModulePicklistValue> initModulesPicklist() {
        List<EUR_DOC_DocServerModulePicklistValue> opts = new List<EUR_DOC_DocServerModulePicklistValue>();
        opts.add(new EUR_DOC_DocServerModulePicklistValue('ALL','ALL'));
        if (Schema.sObjectType.EUR_CRM_GB_Objective__c.isAccessible()) {
            opts.add(new EUR_DOC_DocServerModulePicklistValue('PO','Personal Objectives'));    
        } 
        if (Schema.sObjectType.EUR_CRM_POSM_Audit_Item__c.isAccessible()) {
            opts.add(new EUR_DOC_DocServerModulePicklistValue('POSM','POS Material'));    
        } 
        if (Schema.sObjectType.EUR_CRM_Product_Toolkit__c.isAccessible()) {
            opts.add(new EUR_DOC_DocServerModulePicklistValue('VA','Visit Action'));    
        }
        if (Schema.sObjectType.EUR_CRM_Objectives_Promotions__c.isAccessible()) {
            opts.add(new EUR_DOC_DocServerModulePicklistValue('OP','Objectives / Promotions'));    
        } 
        if (Schema.sObjectType.EUR_CRM_Competitor_Promo_Tracking_Item__c.isAccessible()) {
            opts.add(new EUR_DOC_DocServerModulePicklistValue('CPT','Competitor Promo Tracking'));    
        }
        if (Schema.sObjectType.EUR_CRM_Brand_Security_Infringement__c.isAccessible()) {
            opts.add(new EUR_DOC_DocServerModulePicklistValue('BS','Brand Security')); 
        }
        if (Schema.sObjectType.EUR_CRM_Menu_Feature__c.isAccessible() && Schema.sObjectType.EUR_CRM_Menu_Feature_Items__c.isAccessible()) {
            opts.add(new EUR_DOC_DocServerModulePicklistValue('MENU','Menu Feature')); 
        }
        if (Schema.sObjectType.EUR_CRM_Sales_Order__c.isAccessible() && bSOActive){
            opts.add(new EUR_DOC_DocServerModulePicklistValue('SO','Sales Order'));
        }
        return opts;  
    }

    @AuraEnabled(Cacheable=true)
    public static List<EUR_DOC_DocServerModulePicklistValue> initBSbqPicklist() {
        return getTranslatedPicklistValues('EUR_CRM_Brand_Security_Infringement__c', 'EUR_CRM_Brand_Quality__c');
    }

    @AuraEnabled(Cacheable=true)
    public static boolean checkIfUserIsRussian() {
        boolean retour = false;
        User u = [SELECT EUR_CRM_Country_Code__c FROM User WHERE Id=:UserInfo.getUserId()];
        System.debug(u);
        if (u.EUR_CRM_Country_Code__c!=null && u.EUR_CRM_Country_Code__c.contains('RU')) {
            retour = true;
        }
        return retour;
    }

    @AuraEnabled(Cacheable=true)
    public static boolean checkIfUserIsFinland() {
        boolean isFinland = false;
        User u = [SELECT EUR_CRM_Country_Code__c, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        System.debug(u);
        if ((u.EUR_CRM_Country_Code__c!=null && u.EUR_CRM_Country_Code__c.contains('FI')) || u.profile.Name == 'EUR System Admin') {
            isFinland = true;
        }
        return isFinland;
    }

    @AuraEnabled(Cacheable=true)
    public static boolean checkIfUserHasSO() {
        List<GroupMember> lGroup = [Select Id, group.developerName from groupmember where userorgroupid = :UserInfo.getUserId() and group.developerName = 'EUR_DOC_Sales_Order_Allowed'];
        return lGroup.size() == 1;
    }

    @AuraEnabled(Cacheable=true)
    public static boolean getTaxonomyChainConfigOK() 
    {
        return mapTaxonomyChainField.isEmpty() ? false : true;
    }

    @AuraEnabled(Cacheable=true)
    public static EUR_DOC_PagedResult triggerSearch(String filters, Integer pageNumber) {
        loadPrefix();
        loadFilterTrade();

        EUR_DOC_PagedResult result = initPagedResult(pageNumber);
        if (!String.isEmpty(filters)) {
            Filters searchFilters = (Filters) JSON.deserializeStrict(filters, EUR_DOC_DocServerController.Filters.class);
            System.debug('Filtres sélectionnés: '+searchFilters);
            if (searchFilters.module!=null) {
                if (
                    String.isEmpty(searchFilters.account) && 
                    String.isEmpty(searchFilters.user) &&  
                    String.isEmpty(searchFilters.taxonomychain) && 
                    String.isEmpty(searchFilters.taxonomy) && 
                    String.isEmpty(searchFilters.territory) && 
                    String.isEmpty(searchFilters.region) && 
                    String.isEmpty(searchFilters.op) && 
                    String.isEmpty(searchFilters.opcode) && 
                    String.isEmpty(searchFilters.posm) && 
                    String.isEmpty(searchFilters.b) && 
                    String.isEmpty(searchFilters.bq) && 
                    String.isEmpty(searchFilters.bqs) && 
                    String.isEmpty(searchFilters.bsbq) &&
                    String.isEmpty(searchFilters.sku) && 
                    String.isEmpty(searchFilters.toolkit)) 
                {
                    System.debug('ALL FILTERS ARE EMPTY');
                    result.records = triggerNoFilterSearch(searchFilters,pageNumber);
                    result.records.sort();
                } 
                else if (searchFilters.module.equals('PO')) 
                {
                    result.records = triggerPOSearch(searchFilters,pageNumber);
                    result.records.sort();
                }
                else if (searchFilters.module.equals('MENU')) 
                {
                    result.records = triggerMENUSearch(searchFilters,pageNumber);
                    result.records.sort();
                }
                else if (searchFilters.module.equals('VA')) 
                {
                    result.records = triggerVASearch(searchFilters,pageNumber);
                    result.records.sort();
                }
                else if (searchFilters.module.equals('OP')) 
                {
                    result.records = triggerOPSearch(searchFilters,pageNumber);
                    result.records.sort();
                } 
                else if (searchFilters.module.equals('POSM')) 
                {
                    result.records = triggerPOSMSearch(searchFilters,pageNumber);
                    result.records.sort();
                } 
                else if(searchFilters.module.equals('CPT'))
                {
                    result.records = triggerCPTSearch(searchFilters,pageNumber);
                    result.records.sort();
                }
                else if (searchFilters.module.equals('BS')) 
                {
                    result.records = triggerBSSearch(searchFilters,pageNumber);
                    result.records.sort();
                }
                else if (searchFilters.module.equals('SO')) 
                {
                    result.records = triggerSOSearch(searchFilters,pageNumber);
                    result.records.sort();
                } 
                else if (searchFilters.module.equals('ALL')) 
                {
                    result.records = triggerAllSearch(searchFilters,pageNumber);
                    result.records.addAll(triggerVASearch(searchFilters,pageNumber));
                    result.records.addAll(triggerPOSearch(searchFilters,pageNumber));
                    result.records.addAll(triggerMENUSearch(searchFilters,pageNumber));
                    result.records.addAll(triggerOPSearch(searchFilters,pageNumber));
                    result.records.addAll(triggerPOSMSearch(searchFilters,pageNumber));
                    result.records.addAll(triggerCPTSearch(searchFilters,pageNumber));
                    result.records.addAll(triggerBSSearch(searchFilters,pageNumber));
                    if(bSOActive){
                        result.records.addAll(triggerSOSearch(searchFilters,pageNumber));
                    }
                    result.records.sort();
                }
            }
        }
        //sleep(2000);
        System.debug('Taille liste de records avant pagination: '+result.records.size());
        System.debug('Taille de la pile avant pagination: '+Limits.getHeapSize());
        result = initPostTraitements(result,pageNumber);
        System.debug('Taille de la pile avant retour: '+Limits.getHeapSize());
        System.debug('Temps d\'exécution: '+Limits.getCpuTime());
        System.debug('Liste envoyée au composant: '+result);
        return result;  
    }

    public static List<Object> triggerNoFilterSearch(Filters searchFilters, Integer pageNumber) 
    {
        List<String> criteria = new List<String>();
        String dateClause = initDateFilters(searchFilters);
        System.debug('triggerNoFilterSearch dateClause:'+dateClause);
        List<Object> objs = new List<Object>();
        Integer nbAtts = 0;
        Set<Id> poIds = new Set<Id>();
        Set<Id> vaIds = new Set<Id>();
        Set<Id> vsaIds = new Set<Id>();
        Set<Id> opIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> posmIds = new Set<Id>();
        Set<Id> saiIds = new Set<Id>();
        Set<Id> cptIds = new Set<Id>();
        Set<Id> bsIds = new Set<Id>();
        Set<Id> soIds = new Set<Id>();
        Set<Id> menuIds = new Set<Id>();
        List<Attachment> opAtts = new List<Attachment>();
        List<Attachment> poAtts = new List<Attachment>();
        List<Attachment> accAtts = new List<Attachment>();
        List<Attachment> posmAtts = new List<Attachment>();
        List<Attachment> saiAtts = new List<Attachment>();
        List<Attachment> cptAtts = new List<Attachment>();
        List<Attachment> bsAtts = new List<Attachment>();
        List<Attachment> soAtts = new List<Attachment>();
        List<Attachment> menuAtts = new List<Attachment>();
        //Attachment part of a single search "Visit action"
        List<Attachment> vaAtts = new List<Attachment>();
        List<Attachment> vsaAtts = new List<Attachment>();
        SYSTEM.DEBUG('ATTACHMENT QUERY');
        
        String attachmentQuery = 'SELECT Id,Owner.Name,CreatedDate,ParentId FROM Attachment ' + dateClause + ' ORDER BY CreatedDate DESC';
        System.debug('ATTACHMENT QUERY');
        System.debug(attachmentQuery);
        for (Attachment att : Database.query(attachmentQuery)) {
            if (String.valueOf(att.ParentId).startsWith(mapPrefix.get('PO'))) {
                poIds.add(att.ParentId);
                poAtts.add(att);
            } 
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('MENU'))) {
                menuIds.add(att.ParentId);
                menuAtts.add(att);
            }
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('VA'))) {
                vaIds.add(att.ParentId);
                vaAtts.add(att);
            }
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('VSA'))) {
                vsaIds.add(att.ParentId);
                vsaAtts.add(att);
            }
            else if (String.valueOf(att.ParentId).startsWith(mapPrefix.get('ACC'))) {
                accIds.add(att.ParentId);
                accAtts.add(att);
            } 
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('OP'))) {
                opIds.add(att.ParentId);
                opAtts.add(att);
            } 
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('POSM'))) {
                posmIds.add(att.ParentId);
                posmAtts.add(att);
            }
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('CPT'))) {
                cptIds.add(att.ParentId);
                cptAtts.add(att);
            }
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('BS'))) {
                bsIds.add(att.ParentId);
                bsAtts.add(att);
            }
            else if(String.valueOf(att.ParentId).startsWith(mapPrefix.get('SO'))) {
                soIds.add(att.ParentId);
                soAtts.add(att);
            }
            nbAtts++;
        } 

        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        System.debug('----Acc Size Attachment : ' + accIds.size());
        System.debug('----PO Size Attachment : ' + poIds.size());
        System.debug('----POSM Size Attachment : ' + posmIds.size());
        System.debug('----SAI Size Attachment : ' + saiIds.size());
        System.debug('----OP Size Attachment : ' + opIds.size());
        System.debug('----CPT Size Attachment : ' + cptIds.size());
        System.debug('----BS Size Attachment : ' + bsIds.size());
        System.debug('----SO Size Attachment : ' + soIds.size());
        System.debug('----VA Size Attachment : ' + vaIds.size());
        System.debug('----VSA Size Attachment : ' + vsaIds.size());

        System.debug('triggerNoFilterSearch size:'+nbAtts);  
        if (searchFilters.module.equals('PO') || searchFilters.module.equals('ALL')) {
            
            Map<Id,EUR_CRM_GB_Objective__c> poMap = new Map<Id,EUR_CRM_GB_Objective__c>();

            criteria = new List<String>();//reset
            criteria.add('Id IN :poIds');
            
            for (EUR_CRM_GB_Objective__c po : Database.query(getQuery('PO', searchFilters, criteria))) {
                poMap.put(po.Id,po);
            }
            for (Attachment att : poAtts) {
                if (poMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,poMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (searchFilters.module.equals('VA') || searchFilters.module.equals('ALL')) {
            Map<Id,EUR_CRM_Visit_Action__c> vaMap = new Map<Id,EUR_CRM_Visit_Action__c>();
            Map<Id,EUR_CRM_Visit_Sub_Action__c> vsaMap = new Map<Id,EUR_CRM_Visit_Sub_Action__c>();
            List<String> criteriaVA = new List<String>();
            List<String> criteriaVSA = new List<String>();

            criteriaVA.add('Id IN :vaIds');
            for (EUR_CRM_Visit_Action__c va : Database.query(getQuery('VA', searchFilters, criteriaVA))) {
                vaMap.put(va.Id,va);
            }
            criteriaVSA.add('Id IN :vsaIds');
            for (EUR_CRM_Visit_Sub_Action__c vsa : Database.query(getQuery('VSA', searchFilters, criteriaVSA))) {
                vsaMap.put(vsa.Id,vsa);
            }
            for (Attachment att : vaAtts) {
                if (vaMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,vaMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
            for (Attachment att : vsaAtts) {
                if (vsaMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,vsaMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (searchFilters.module.equals('OP') || searchFilters.module.equals('ALL')) {
            
            Map<Id,EUR_CRM_OP_Visit_Action__c> opMap = new Map<Id,EUR_CRM_OP_Visit_Action__c>();
            criteria = new List<String>();
            criteria.add('Id IN :opIds');
            
            for (EUR_CRM_OP_VIsit_Action__c op : Database.query(getQuery('OP', searchFilters, criteria))) {
                opMap.put(op.Id,op);
            }
            for (Attachment att : opAtts) {
                if (opMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,opMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (searchFilters.module.equals('MENU') || searchFilters.module.equals('ALL')) {
            Map<Id,EUR_CRM_Menu_Feature__c> menuMap = new Map<Id,EUR_CRM_Menu_Feature__c>();
            criteria = new List<String>();
            criteria.add('Id IN :menuIds');
            for (EUR_CRM_Menu_Feature__c menu : Database.query(getQuery('MENU', searchFilters, criteria))) {
                menuMap.put(menu.Id,menu);
            }
            for (Attachment att : menuAtts) {
                if (menuMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,menuMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (searchFilters.module.equals('POSM') || searchFilters.module.equals('ALL')) {
            
            Map<Id,EUR_CRM_POSM_Audit_Item__c> posmMap = new Map<Id,EUR_CRM_POSM_Audit_Item__c>();
            criteria = new List<String>();
            criteria.add('Id IN :posmIds');
            
            for (EUR_CRM_POSM_Audit_Item__c posm : Database.query(getQuery('POSM', searchFilters, criteria))) {
                posmMap.put(posm.Id,posm);
            }
            for (Attachment att : posmAtts) {
                if (posmMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,posmMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }

        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (searchFilters.module.equals('CPT') || searchFilters.module.equals('ALL')) {
            
            Map<Id,EUR_CRM_Competitor_Promo_Tracking_Item__c> cptMap = new Map<Id,EUR_CRM_Competitor_Promo_Tracking_Item__c>();
            criteria = new List<String>();
            criteria.add('Id IN :cptIds');
            
            for (EUR_CRM_Competitor_Promo_Tracking_Item__c cpt : Database.query(getQuery('CPT', searchFilters, criteria))) {
                cptMap.put(cpt.Id,cpt);
            }
            for (Attachment att : cptAtts) {
                if (cptMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,cptMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (searchFilters.module.equals('BS') || searchFilters.module.equals('ALL')) {
            
            Map<Id,EUR_CRM_Brand_Security_Infringement__c> bsMap = new Map<Id,EUR_CRM_Brand_Security_Infringement__c>();
            criteria = new List<String>();
            criteria.add('Id IN :bsIds');
            
            for (EUR_CRM_Brand_Security_Infringement__c bs : Database.query(getQuery('BS', searchFilters, criteria))) {
                bsMap.put(bs.Id,bs);
            }
            for (Attachment att : bsAtts) {
                if (bsMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,bsMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (bSOActive && (searchFilters.module.equals('SO') || searchFilters.module.equals('ALL'))) {
            
            Map<Id,EUR_CRM_Sales_Order__c> soMap = new Map<Id,EUR_CRM_Sales_Order__c>();
            criteria = new List<String>();
            criteria.add('Id IN :soIds');
            
            for (EUR_CRM_Sales_Order__c so : Database.query(getQuery('SO', searchFilters, criteria))) {
                soMap.put(so.Id,so);
            }
            for (Attachment att : soAtts) {
                if (soMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,soMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        }
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        if (searchFilters.module.equals('ALL')) {
            criteria = new List<String>();
            criteria.add('Id IN :accIds');
            
            Map<Id,EUR_CRM_Account__c> accMap = new Map<Id,EUR_CRM_Account__c>();
            for (EUR_CRM_Account__c acc : Database.query(getQuery('ALL', searchFilters, criteria))) {
                accMap.put(acc.Id,acc);
            }
            for (Attachment att : accAtts) {
                if (accMap.get(att.ParentId)!=null) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,accMap.get(att.ParentId)); 
                    objs.add(obj);     
                }
            }
        } 
        System.debug('Number of SOQL : ' + Limits.getAggregateQueries());
        System.debug('Temps d\'exécution apres Requête No Filter: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;    
    }

    public static List<Object> triggerAllSearch(Filters searchFilters, Integer pageNumber) 
    {
        
        List<Object> objs = new List<Object>();
        System.debug('Temps d\'exécution avant Requête ALL: '+Limits.getCpuTime());
        
        if(String.isEmpty(searchFilters.b) && String.isEmpty(searchFilters.bq) && String.isEmpty(searchFilters.bqs)){
            for (EUR_CRM_Account__c acc : Database.query(getQuery('ALL', searchFilters, new List<String>()))) {
                for (Attachment att : acc.Attachments) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,acc); 
                    objs.add(obj); 
                }
            }
        }
        //System.debug('triggerAllSearch size:'+query.size());
        System.debug('Temps d\'exécution apres Requête ALL: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<Object> triggerPOSearch(Filters searchFilters, Integer pageNumber) 
    {
        System.debug('Temps d\'exécution avant Requête PO: '+Limits.getCpuTime());
        
        List<Object> objs = new List<Object>();
        if(String.isEmpty(searchFilters.b) && String.isEmpty(searchFilters.bqs)){
            for (EUR_CRM_GB_Objective__c qi : Database.query(getQuery('PO', searchFilters, new List<String>()))) {
                for (Attachment att : qi.Attachments) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,qi); 
                    objs.add(obj); 
                }
            }
        }
        System.debug('Temps d\'exécution apres Requête PO: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<Object> triggerOPSearch(Filters searchFilters, Integer pageNumber) {
        
        List<Object> objs = new List<Object>();
        for (EUR_CRM_OP_VIsit_Action__c op : Database.query(getQuery('OP', searchFilters, new List<String>()))) {
            for (Attachment att : op.Attachments) {
                EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,op); 
                objs.add(obj); 
            }
        }
        System.debug('Temps d\'exécution apres Requête OP: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<Object> triggerPOSMSearch(Filters searchFilters, Integer pageNumber) {
        
        List<Object> objs = new List<Object>();
        if(String.isEmpty(searchFilters.bqs)){
            for (EUR_CRM_POSM_Audit_Item__c posm : Database.query(getQuery('POSM', searchFilters, new List<String>()))) {
                for (Attachment att : posm.Attachments) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,posm); 
                    objs.add(obj); 
                }
            }
        }
        System.debug('Temps d\'exécution apres Requête POSM: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<Object> triggerMENUSearch(Filters searchFilters, Integer pageNumber) {
        System.debug('ENTER MENU SEARCH');
        List<Object> objs = new List<Object>();
        //we don't want to trigger the search if product filter different from brand / Brand quality
        if(String.isEmpty(searchFilters.posm) && String.isEmpty(searchFilters.bqs) && String.isEmpty(searchFilters.sku) && String.isEmpty(searchFilters.toolkit)){
            System.debug('THE QUERY');
            System.debug(getQuery('MENU', searchFilters, new List<String>()));
            for (EUR_CRM_Menu_Feature__c m : Database.query(getQuery('MENU', searchFilters, new List<String>()))) {
                System.debug('Menu found');
                for (Attachment att : m.Attachments) {
                    System.debug('Menu attachment found');
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,m); 
                    objs.add(obj); 
                }
            }
        }
        System.debug('Temps d\'exécution apres Requête POSM: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<Object> triggerVASearch(Filters searchFilters, Integer pageNumber) {
        
        List<Object> objs = new List<Object>();
        //no query when a product filter is apply and not concerned by our module
        
        Set<Id> vaIds = new Set<Id>();
        //What do we want?
        //Here we want to return the VA/VSA that matches the criteria
        //But if we retrieve a VSA we want to retrieve as well its related VA
        //Same thinking if we retrieve VA we also want to retrieve the related VSA
        //For VSA level we can query the parent => SO all good (and if nothing is retrieve it means we have no VSA)
        //For VA level we don't want make another sub query, so we will use the VA ID found in the VSA query and concat with product filter for VA
        //This is important only when some specific filter applies (product or toolkit) because general filter should return the same result for both objects
        //IMPORTANT :Execute VSA FIRST
        List<String> criterias = new List<String>();
        
        //must be executed first
        for (EUR_CRM_Visit_Sub_Action__c vsa : Database.query(getQuery('VSA', searchFilters, new List<String>()))) {
            vaIds.add(vsa.EUR_CRM_Visit_Action__c);
            for (Attachment att : vsa.Attachments) {
                EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,vsa); 
                objs.add(obj); 
            }
        }

        //Execute in second
        for (EUR_CRM_Visit_Action__c va : Database.query(getQuery('VA', searchFilters, new List<String>()))) {
            for (Attachment att : va.Attachments) {
                EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,va); 
                objs.add(obj); 
            }
        }
        
        System.debug('Temps d\'exécution apres Requête VA: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }
    
    
    
    public static List<Object> triggerCPTSearch(Filters searchFilters, Integer pageNumber) {
        
        List<Object> objs = new List<Object>();
        if(String.isEmpty(searchFilters.b)){
            for (EUR_CRM_Competitor_Promo_Tracking_Item__c cpt : Database.query(getQuery('CPT', searchFilters, new List<String>()))) {
                for (Attachment att : cpt.Attachments) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,cpt); 
                    objs.add(obj); 
                }
            }
        }
        System.debug('Temps d\'exécution apres Requête CPT: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<Object> triggerBSSearch(Filters searchFilters, Integer pageNumber) {
        
        List<Object> objs = new List<Object>();
        if(String.isEmpty(searchFilters.b) && String.isEmpty(searchFilters.bq) && String.isEmpty(searchFilters.bqs)){
            for (EUR_CRM_Brand_Security_Infringement__c bs : Database.query(getQuery('BS', searchFilters, new List<String>()))) {
                for (Attachment att : bs.Attachments) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,bs); 
                    objs.add(obj); 
                }
            }
        }
        System.debug('Temps d\'exécution apres Requête BS: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<Object> triggerSOSearch(Filters searchFilters, Integer pageNumber) {
        
        List<Object> objs = new List<Object>();
        if(String.isEmpty(searchFilters.b) && String.isEmpty(searchFilters.bq) && String.isEmpty(searchFilters.bqs)){
            for (EUR_CRM_Sales_Order__c so : Database.query(getQuery('SO', searchFilters, new List<String>()))) {
                for (Attachment att : so.Attachments) {
                    EUR_DOC_CompoundObject obj = new EUR_DOC_CompoundObject(att,so); 
                    objs.add(obj); 
                }
            }
        }
        System.debug('Temps d\'exécution apres Requête SO: '+Limits.getCpuTime());
        EUR_DOC_DocServerController.totalItemCount += objs.size();
        return objs;
    }

    public static List<String> initGenericFilters(Filters searchFilters,String prefix, String masterDetail) 
    {
        String accountId, userId, earlierDate, laterDate, chainName, taxName, terName, regName, opName;
        String whereClause = '';
        String sChannelQuery = '';
        String sTaxonomyChainQuery = '';
        Boolean bChannelWhereAdded = false;
        List<String> criteria = new List<String>();
        if (prefix!='' && searchFilters.earlierDate!=null && searchFilters.laterDate!=null) {
            earlierDate = String.valueOf(searchFilters.earlierDate).substring(0,10)+'T00:00:00z';
            laterDate = String.valueOf(searchFilters.laterDate.addDays(1)).substring(0,10)+'T00:00:00z';
            criteria.add('((CreatedDate >='+earlierDate+' AND CreatedDate <='+laterDate+') OR (LastModifiedDate >='+earlierDate+' AND LastModifiedDate <='+laterDate+'))');
        }
        if (!String.isEmpty(searchFilters.account)) {
            accountId = searchFilters.account;
            criteria.add(prefix + 'Id = \'' + accountId + '\'');
        }
        if (!String.isEmpty(searchFilters.user)) {
            userId = searchFilters.user;
            criteria.add(masterDetail + 'OwnerId = \'' + userId + '\'');
        }
        //channel filters start
        sChannelQuery = '(';
        if (searchFilters.isOnTrade) {
            sChannelQuery += prefix + 'EUR_CRM_Channel__c IN :in_ON';
            bChannelWhereAdded = true;
        }
        if (searchFilters.isOffTrade) {
            if (bChannelWhereAdded){
                sChannelQuery += ' OR ';
            }
            sChannelQuery += prefix + 'EUR_CRM_Channel__c IN :in_OFF';
            bChannelWhereAdded = true;
        }
        if (searchFilters.isDistributor) {
            if (bChannelWhereAdded){
                sChannelQuery += ' OR ';
            }
            sChannelQuery += prefix + 'EUR_CRM_Channel__c IN :in_DISTRIB';
            bChannelWhereAdded = true;
        }
        if (searchFilters.isOther) {
            if (bChannelWhereAdded){
                sChannelQuery += ' OR ';
            }
            sChannelQuery += prefix + 'EUR_CRM_Channel__c IN :in_OTHER';
            bChannelWhereAdded = true;
        }
        sChannelQuery += ')';
        criteria.add(sChannelQuery);
        //channel filters end
        if (!String.isEmpty(searchFilters.taxonomychain)) {
            chainName = searchFilters.taxonomychain;
            sTaxonomyChainQuery = '';
            for(String sField : mapTaxonomyChainField.keySet()){
                if(sTaxonomyChainQuery == ''){
                    sTaxonomyChainQuery = '(';
                }
                else {
                    sTaxonomyChainQuery += ' OR ';
                }
                sTaxonomyChainQuery += '(' + prefix + 'EUR_CRM_Country_Code__c IN (' + mapTaxonomyChainField.get(sField) + ') AND ' + prefix + 'EUR_JB_Customer_Taxonomy__r.' + sField + ' like \'%' + chainName + '%\')';
            }
            if(sTaxonomyChainQuery != ''){
                sTaxonomyChainQuery += ')';
                criteria.add(sTaxonomyChainQuery);
            }
        }
        if (!String.isEmpty(searchFilters.taxonomy)) {
            taxName = searchFilters.taxonomy;
            criteria.add(prefix + 'EUR_JB_Customer_Taxonomy__c = \'' + taxName + '\'');
        }
        if (!String.isEmpty(searchFilters.territory)) {
            terName = searchFilters.territory;
            criteria.add(prefix + 'EUR_CRM_Territory__c = \'' + terName + '\'');
        }
        if (!String.isEmpty(searchFilters.region)) {
            regName = searchFilters.region;
            criteria.add(prefix + 'EUR_CRM_Territory__r.EUR_CRM_Region__c = \'' + regName + '\'');
        }
        
        criteria.add(prefix + 'EUR_CRM_Epicenter__c = '+ searchFilters.epicenter);    
        
        return criteria;
    }

    private static String buildWhere(List<String> criteria) 
    {                 
        return criteria.size() > 0 ? 'WHERE ' + String.join( criteria, ' AND ' ) : '';
    }

    public static String initDateFilters(Filters searchFilters) {
        String whereClause = '';
        String earlierDate, laterDate;
        String[] criteria = new String[]{};
        if (searchFilters.earlierDate!=null) {
            earlierDate = String.valueOf(searchFilters.earlierDate).substring(0,10)+'T00:00:00z';
            criteria.add('CreatedDate >=' + earlierDate);
        }
        if (searchFilters.laterDate!=null) {
            laterDate = String.valueOf(searchFilters.laterDate.addDays(1)).substring(0,10)+'T00:00:00z';
            criteria.add('CreatedDate <=' + laterDate);
        }
        criteria.addAll(generateSFDCObjectFilter(searchFilters.module));
        if (criteria.size() > 0) {
            whereClause = 'WHERE ' + String.join( criteria, ' AND ' );
        }                      
        return whereClause;
    }

    public static List<String> generateSFDCObjectFilter(String module) {
        List<String> retour = new List<String>();
        String filterType = '';
        Map<String, String> moduleObjectAPINameMap = new Map<String, String>();
        for(EUR_DOC_PrefixObj__mdt item : [SELECT DeveloperName,EUR_DOC_API_Object_Name__c FROM EUR_DOC_PrefixObj__mdt]) {
            moduleObjectAPINameMap.put(item.DeveloperName, item.EUR_DOC_API_Object_Name__c);
        }
        filterType = '(Name LIKE \'%.png\' OR Name LIKE \'%.jpg\' OR Name LIKE \'%.jpeg\' OR Name LIKE \'%.gif\'';
        if (bSOActive && (module.equals('ALL') || module.equals('SO'))){
            filterType = '((' + filterType+ ') AND Parent.Type!=\'' + moduleObjectAPINameMap.get('SO') + '\') OR (Name LIKE \'%.pdf\' AND Parent.Type=\'' + moduleObjectAPINameMap.get('SO') + '\')';
        }
        filterType += ')';
        retour.add(filterType);
        if (!module.equals('ALL')) {
            if(module.equals('VA')) {
                //exception we need VA & VSA
                retour.add('(Parent.Type=\''+moduleObjectAPINameMap.get(module)+'\' OR Parent.Type=\''+moduleObjectAPINameMap.get('VSA')+'\')');
            } else {
                retour.add('Parent.Type=\''+moduleObjectAPINameMap.get(module)+'\'');
            }
            
        } else {
            String listParentType='(';
            for(String s : moduleObjectAPINameMap.keySet()) {
                if (listParentType.length()==1) {
                    if(s != 'SO' || bSOActive){
                        listParentType += 'Parent.Type=\''+moduleObjectAPINameMap.get(s)+'\'';
                    }
                } else {
                    if(s != 'SO' || bSOActive){
                        listParentType += ' OR Parent.Type=\''+moduleObjectAPINameMap.get(s)+'\'';
                    }
                }
            }
            retour.add(listParentType+')');
        }
        return retour;
    }

    public static EUR_DOC_PagedResult initPostTraitements(EUR_DOC_PagedResult result, Integer pageNumber) {
        Integer offset = (pageNumber - 1) * result.pageSize; 
        List<Object> objs = new List<Object>();  
        for (Integer i=offset; i<offset+result.pageSize; i++) {
            if (i<result.records.size()) {
                objs.add(result.records[i]);
            }
        }
        result.records = objs;
        result.totalItemCount = EUR_DOC_DocServerController.totalItemCount;
        return result;
    }

    public static String getCountryCode(String prefix) {
        String whereClause='';
        String pfName = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()].Name;
        //System.debug(!pfName.contains('Admin')+' '+!pfName.contains('admin'));
        if (!pfName.contains('Admin') && !pfName.contains('admin')) {
            whereClause = ' AND '+prefix+'EUR_CRM_Country_Code__c=\''+[SELECT EUR_CRM_Country_Code__c FROM User WHERE Id=:UserInfo.getUserId()].EUR_CRM_Country_Code__c+'\'';
        }
        return whereClause;
    }

    public static EUR_DOC_PagedResult initPagedResult(Integer pageNumber) {
        EUR_DOC_PagedResult result =  new EUR_DOC_PagedResult();
        result.pageSize = EUR_DOC_DocServerController.PAGE_SIZE;
        result.pageNumber = pageNumber;
        result.records = new List<Object>();
        return result;
    }

    /*private static void sleep(integer milliseconds)  {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do {
            timeDiff = System.now().getTime() - firstTime.getTime();
        } while(timeDiff <= milliseconds);      
    }*/

    @AuraEnabled(Cacheable=true)
    public static List<Object> getPictureBody(List<String> listIds) {
        List<Object> objs = new List<Object>();  
        for (Attachment att : [SELECT Id,Name,Body FROM Attachment WHERE Id IN :listIds]) {
            objs.add(new AttObj(att));
        }
        return objs;
    }

    public class AttObj {
        @AuraEnabled
        public String id { get;set; }

        @AuraEnabled
        public String extension { get;set; }
        
        @AuraEnabled
        public String data { get;set; }

        public AttObj(Attachment att) {
            this.id = att.Id;
            this.data = EncodingUtil.base64Encode(att.Body);
            List<String> splittedName = String.valueOf(att.Name).split('\\.');
            this.extension = '.'+splittedName[splittedName.size()-1];
        }
    }


    

    public static String getQuery(String module, Filters searchFilters, List<String> otherCriteria) {
        System.debug('GET QUERY for ' + module);
        List<String> criteria = new List<String>();
        criteria.addAll(otherCriteria);

        if(module.equals('VA')) {
            String productFilter = '';
            if(!String.isEmpty(searchFilters.toolkit)) {
                productFilter = 'EUR_CRM_Product_Toolkit__c = \'' + searchFilters.toolkit + '\'';
            } else if(!String.isEmpty(searchFilters.sku)) {
                productFilter = 'EUR_CRM_SKU__c = \'' + searchFilters.sku + '\'';
            } else if(!String.isEmpty(searchFilters.bq)) {
                productFilter = 'EUR_CRM_Brand_Quality__c = \'' + searchFilters.bq + '\'';
            } else if(!String.isEmpty(searchFilters.bqs)) {
                productFilter = 'EUR_CRM_Brand_Quality_Size__c = \'' + searchFilters.bqs + '\'';
            } else if(!String.isEmpty(searchFilters.b)) {
                productFilter = 'EUR_CRM_Brand__c = \'' + searchFilters.b + '\'';
            }
            if(productFilter != '') {
                //vaIds is created before the call of getQuery
                criteria.add('(Id IN :vaIds OR ' + productFilter + ')');
            }
            return buildQuery(
                searchFilters, 
                'EUR_CRM_Visit_ID__r.EUR_CRM_Account__r.', 
                'EUR_CRM_Visit_Action__c', 
                '',
                criteria,
                new List<String>()
            );
        } else if(module.equals('VSA')) {
            
            if(!String.isEmpty(searchFilters.toolkit)) {
                criteria.add('EUR_CRM_Visit_Action__r.EUR_CRM_Product_Toolkit__c = \'' + searchFilters.toolkit + '\'');
            } else if(!String.isEmpty(searchFilters.sku)) {
                criteria.add('(EUR_CRM_SKU__c = \'' + searchFilters.sku + '\' OR EUR_CRM_Visit_Action__r.EUR_CRM_SKU__c = \'' + searchFilters.sku + '\')');
            } else if(!String.isEmpty(searchFilters.bq)) {
                criteria.add('(EUR_CRM_Brand_Quality__c = \'' + searchFilters.bq + '\' OR EUR_CRM_Visit_Action__r.EUR_CRM_Brand_Quality__c = \'' + searchFilters.bq + '\')');
            } else if(!String.isEmpty(searchFilters.bqs)) {
                criteria.add('(EUR_CRM_Brand_Quality_Size__c = \'' + searchFilters.bqs + '\' OR EUR_CRM_Visit_Action__r.EUR_CRM_Brand_Quality_Size__c = \'' + searchFilters.bqs + '\')');
            } else if(!String.isEmpty(searchFilters.b)) {
                criteria.add('(EUR_CRM_Brand__c = \'' + searchFilters.b + '\' OR EUR_CRM_Visit_Action__r.EUR_CRM_Brand__c = \'' + searchFilters.b + '\')');
            }
            System.debug('VSA CRITERIA');
            System.debug(criteria);
            
            return buildQuery(
                searchFilters, 
                'EUR_CRM_Visit_Action__r.EUR_CRM_Visit_ID__r.EUR_CRM_Account__r.', 
                'EUR_CRM_Visit_Sub_Action__c', 
                'EUR_CRM_Visit_Action__r.',
                criteria,
                new List<String> {'EUR_CRM_Visit_Action__c'}
            );
        }
        else if(module.equals('MENU')) {
            if(!String.isEmpty(searchFilters.b)) {
                criteria.add('Id IN (SELECT EUR_CRM_Menu_Feature__c FROM EUR_CRM_Menu_Feature_Items__c WHERE EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c = \'' + searchFilters.b + '\')');
            } else if(!String.isEmpty(searchFilters.bq)) {
                criteria.add('Id IN (SELECT EUR_CRM_Menu_Feature__c FROM EUR_CRM_Menu_Feature_Items__c WHERE EUR_CRM_Brand_Quality__c = \'' + searchFilters.bq + '\')');
            }
            System.debug('CRITERIA MENU');
            System.debug(criteria);
            return buildQuery(
                searchFilters, 
                'EUR_CRM_Account__r.', 
                'EUR_CRM_Menu_Feature__c', 
                'EUR_CRM_Account__r.',
                criteria,
                new List<String>()
            );
        }
        else if(module.equals('OP')) {
            if(!String.isEmpty(searchFilters.op)) {
                criteria.add('EUR_CRM_OP_Account_in_Promo__r.EUR_CRM_Objectives_Promotions__c = \'' + searchFilters.op + '\'');
            }
            if(!String.isEmpty(searchFilters.opcode)) {
                criteria.add('EUR_CRM_OP_Account_in_Promo__r.EUR_CRM_Objectives_Promotions__r.EUR_CRM_MAF_ID__c like \'%' + searchFilters.opcode + '%\'');
            }
            
            if(!String.isEmpty(searchFilters.b)) {
                criteria.add('EUR_CRM_OP_Product__r.EUR_CRM_Brand__c = \'' + searchFilters.b + '\'');
            } else if(!String.isEmpty(searchFilters.bq)) {
                criteria.add('EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__c = \'' + searchFilters.bq + '\'');
            } else if(!String.isEmpty(searchFilters.bqs)) {
                criteria.add('EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__c = \'' + searchFilters.bqs + '\'');
            }
            return buildQuery(
                searchFilters, 
                'EUR_CRM_OP_Account_in_Promo__r.EUR_CRM_Account__r.', 
                'EUR_CRM_OP_Visit_Action__c', 
                'EUR_CRM_Visit__r.',
                criteria,
                new List<String>()
            );
        } 
        else if(module.equals('PO')) 
        {
            if(!String.isEmpty(searchFilters.bq)) {
                criteria.add('EUR_CRM_Brand_Quality_EU__c = \'' + searchFilters.bq + '\'');
            }
            return buildQuery(
                searchFilters, 
                'EUR_CRM_Account__r.', 
                'EUR_CRM_GB_Objective__c', 
                '',
                criteria,
                new List<String>()
            );
        }
        else if(module.equals('POSM')) 
        {
            if(!String.isEmpty(searchFilters.posm)) {
                criteria.add('EUR_CRM_POS_Material__c = \'' + searchFilters.posm + '\'');
            }
            //shouldn't be separated, if we look for a specific posm we shouldn't look for a brand/bq
            //But I don't wanna change the behavior, it should work anyway
            if(!String.isEmpty(searchFilters.b)) {
                criteria.add('EUR_CRM_POS_Material__r.EUR_CRM_Brand__c = \'' + searchFilters.b + '\'');
            } else if(!String.isEmpty(searchFilters.bq)) {
                criteria.add('EUR_CRM_POS_Material__r.EUR_CRM_Brand_Quality__c = \'' + searchFilters.bq + '\'');
            }
            return buildQuery(
                searchFilters,
                'EUR_CRM_POSM_Audit__r.EUR_CRM_Account__r.',
                'EUR_CRM_POSM_Audit_Item__c',
                'EUR_CRM_POSM_Audit__r.EUR_CRM_Account__r.',
                criteria,
                new List<String>()
            );
        }
        
        else if(module.equals('CPT')) 
        {
            if(!String.isEmpty(searchFilters.bq)) {
                criteria.add('EUR_CRM_Brand_Quality__c = \'' + searchFilters.bq + '\'');
            } else if(!String.isEmpty(searchFilters.bqs)) {
                criteria.add('EUR_CRM_Brand_Quality_Size__c = \'' + searchFilters.bqs + '\'');
            }
            return buildQuery(
                searchFilters,
                'EUR_CRM_Competitor_Promo_Tracking__r.EUR_CRM_Account_Name__r.',
                'EUR_CRM_Competitor_Promo_Tracking_Item__c',
                'EUR_CRM_Competitor_Promo_Tracking__r.',
                criteria,
                new List<String>()
            );
        }
        else if(module.equals('BS')) 
        {
            if(!String.isEmpty(searchFilters.bsbq)) {
                criteria.add('EUR_CRM_Brand_Quality__c = \'' + searchFilters.bsbq + '\'');
            }
            return buildQuery(
                searchFilters,
                'EUR_CRM_Visit_ID__r.EUR_CRM_Account__r.',
                'EUR_CRM_Brand_Security_Infringement__c',
                '',
                criteria,
                new List<String>()
            );
        }
        else if(module.equals('SO')) 
        {
            criteria.add('RecordType.developername = \'EUR_Free_Goods_from_Stock\'');

            return buildQuery(
                searchFilters,
                'EUR_CRM_Account__r.',
                'EUR_CRM_Sales_Order__c',
                'EUR_CRM_Account__r.',
                criteria,
                new List<String>()
            );
        }
        else //if(module.equals('ALL')) 
        {
            
            return buildQuery(
                searchFilters, 
                '', 
                'EUR_CRM_Account__c', 
                '',
                criteria,
                new List<String>()
            );
        }
    }

    
    /*
    * Use get Query not this function
    */
    public static String buildQuery(Filters searchFilters, String prefix, String objectName, String masterDetail, List<String> otherCriteria, List<String> moreFields) 
    {
        // (String.isEmpty() ? '' : prefixprefix + 'Id, ') ==> Quand on est en mod ALL on va récupéré deux fois Id sans cette restriction
        String fields = 'Id, ' + masterDetail + 'OwnerId, ' + masterDetail + 'Owner.Name, ' + (String.isEmpty(prefix) ? '' : prefix + 'Id, ') + prefix + 'Name, '  
        + prefix + 'EUR_CRM_Street__c, ' + prefix + 'EUR_CRM_City__c, ' + prefix + 'EUR_CRM_Region__c, ' + prefix + 'EUR_CRM_Territory__r.Name' + (moreFields.size() > 0 ? ',' + String.join(moreFields, ','): '');

        String dateClause = initDateFilters(searchFilters);
        countryCode = getCountryCode(prefix);

        List<String> defaultCriteria = initGenericFilters(searchFilters, prefix, masterDetail);
        defaultCriteria.addAll(otherCriteria);

        

        String whereClause = buildWhere(defaultCriteria);
        
        String query = 'SELECT ' + fields + ', (SELECT Id,Owner.Name,CreatedDate FROM Attachments ' + dateClause + ' ORDER BY CreatedDate DESC) FROM ' + objectName + ' ' + whereClause + countryCode + ' ORDER BY CreatedDate DESC';
        
        System.debug('Full Query');
        System.debug(query);
        return query;
    }

    private static void loadFilterTrade() 
    {
        
        if(in_ON == null || in_OFF == null || IN_DISTRIB == null || IN_OTHER == null) {
            Map<String, List<String>> mapTrade_values = new Map<String, List<String>>();
            for(EUR_DOC_FilterTrade__mdt ft : [SELECT DeveloperName, EUR_DOC_Accepted_Values__c FROM EUR_DOC_FilterTrade__mdt]) 
            {
                mapTrade_values.put(ft.DeveloperName, ft.EUR_DOC_Accepted_Values__c.split(';'));
            }
            in_ON = mapTrade_values.get('ON');
            in_OFF = mapTrade_values.get('OFF');
            IN_DISTRIB = mapTrade_values.get('Distributor');
            IN_OTHER = mapTrade_values.get('Others');
            System.debug('ON : ' + in_ON);
            System.debug('OFF : ' + in_OFF);
            System.debug('Distributor : ' + IN_DISTRIB);
            System.debug('Others : ' + IN_OTHER);
        }
    }

    private static void loadPrefix() 
    {
        if(mapPrefix == null) 
        {
            mapPrefix = new Map<String, String>();
            for(EUR_DOC_PrefixObj__mdt prefix : [SELECT MasterLabel, DeveloperName FROM EUR_DOC_PrefixObj__mdt]) 
            {
                mapPrefix.put(prefix.DeveloperName, prefix.MasterLabel);
            }
            System.debug(mapPrefix);
        }
    }

    private static MAP<String,String> loadTaxonomyChainConfig() 
    {
        String pfName = '', userCountryCode = '';

        Map<String, String> mapTempTaxonomyChainField = new Map<String, String>();

        pfName = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()].Name;
        userCountryCode = [SELECT EUR_CRM_Country_Code__c FROM User WHERE Id=:UserInfo.getUserId()].EUR_CRM_Country_Code__c;

        for(EUR_DOC_AFFILIATE_PARAM__mdt param : [SELECT DeveloperName, EUR_DOC_Taxonomy_Chain_Field__c FROM EUR_DOC_AFFILIATE_PARAM__mdt]) 
        {
            if (pfName.contains('Admin') || pfName.contains('admin') || userCountryCode.contains(param.DeveloperName)) {
                if(mapTempTaxonomyChainField.get(param.EUR_DOC_Taxonomy_Chain_Field__c) == null){
                    mapTempTaxonomyChainField.put(param.EUR_DOC_Taxonomy_Chain_Field__c, '\'' + param.DeveloperName + '\'');
                }
                else {
                    mapTempTaxonomyChainField.put(param.EUR_DOC_Taxonomy_Chain_Field__c, mapTempTaxonomyChainField.get(param.EUR_DOC_Taxonomy_Chain_Field__c) + ',\'' + param.DeveloperName + '\'');
                }
            }
        }
        System.debug('mapTempTaxonomyChainField: ' + mapTempTaxonomyChainField);
        return mapTempTaxonomyChainField;        
    }

    private static List<EUR_DOC_DocServerModulePicklistValue> getTranslatedPicklistValues(String objApiName, String fieldApiName)
    {
        List<EUR_DOC_DocServerModulePicklistValue> options = new List<EUR_DOC_DocServerModulePicklistValue>();
        options.add(new EUR_DOC_DocServerModulePicklistValue('','--None--'));
        for (Schema.PicklistEntry pke: Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPickListValues()) {
            if(pke.isActive()){
                options.add(new EUR_DOC_DocServerModulePicklistValue(pke.getValue(),pke.getLabel()));
            }
        }
        return options;
    }

} //end of class