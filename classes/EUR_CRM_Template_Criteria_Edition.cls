public with sharing class EUR_CRM_Template_Criteria_Edition {
    
    public static List<String> colors = new List<String> {
        '0065CF', //Blue / Turquoise
        'FF0000', //red - Light red
        '0D8A00', //green - Light green
        //'A3A500', //yellow - light yellow - removed, looks a bit green some might complain
        'FF7C00', //orange - Light orange
        'B800AA', //purple - light purple,
        '7A1800', //marron & Light
        'C8C6C6', //black & grey
        '00EEFA', //Blue / Turquoise
        'FFADAD', //red - Light red
        'CDFFAC', //green - Light green
        'FEFF84', //yellow - light yellow
        'FFC085', //orange - Light orange
        'FFAEF9', //purple - light purple,
        'D6A599', //marron & Light
        '000000' //black & grey
    };

    private static EUR_CRM_JB_Template__c getTpl(Id templateId) {
        return [SELECT Id, RecordType.DeveloperName, Name FROM EUR_CRM_JB_Template__c WHERE Id = :templateId];
    }


    
    @AuraEnabled
    public static Data loadData(Id templateId, Id regionId) {
        
        EUR_CRM_JB_Template__c template = getTpl(templateId);
        
        String rtGot        = getRecordTypeMap(template.RecordType.DeveloperName, 'TPLC_GOT');
        String rtIL         = getRecordTypeMap(template.RecordType.DeveloperName, 'TPLC_IL');
        String rtVP         = getRecordTypeMap(template.RecordType.DeveloperName, 'TPLC_VP');
        String rtCriteria   = getRecordTypeMap(template.RecordType.DeveloperName, 'TPLC_CRITERIA');

        
        
        Data data = new Data();
        //No need to load anything
        if(rtGot == null || rtIL == null || rtVp == null || rtCriteria == null) {
            return data;
        }

        data.hasAllRequiredMetadata = true;

        List<EUR_CRM_PRS_Group_Outlet_Type__c> GOTS = [
            SELECT Id, EUR_CRM_PRS_Group_Outlet_Name__c, EUR_CRM_Region__c, EUR_CRM_Region__r.Name, 
            (SELECT Id, EUR_CRM_PRS_Outlet_Type_Name__c FROM EUR_CRM_PRS_Outlet_Type__r) 
            FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE RecordType.DeveloperName = :rtGot];
        
            Set<Id> regionsId = new Set<Id>();
        for(EUR_CRM_PRS_Group_Outlet_Type__c got : GOTS) {
            if(regionsId.add(got.EUR_CRM_Region__c)) {
                Picklist r = new Picklist();
                r.value = got.EUR_CRM_Region__c;
                r.label = (r.value == null ? 'Apply to all regions' : got.EUR_CRM_Region__r.Name);
                data.regions.add(r);
            }

        }

        List<EUR_CRM_PRS_Seg_Aspect__c> ILS = [SELECT Id, EUR_CRM_Name__c FROM EUR_CRM_PRS_Seg_Aspect__c WHERE RecordType.DeveloperName = :rtIL];
        
        List<EUR_CRM_PRS_Seg_Aspect__c> VPS = [SELECT Id, EUR_CRM_Name__c FROM EUR_CRM_PRS_Seg_Aspect__c WHERE RecordType.DeveloperName = :rtVP];
       
        Set<Id> templatesId = new Set<Id>();
        Map<Id, Legend> legends = new Map<Id, Legend>();
        
        Integer colorIndex = 0;

        Map<String, EUR_CRM_JB_Template_Criteria__c> criterias = new Map<String, EUR_CRM_JB_Template_Criteria__c>();
        for(EUR_CRM_JB_Template_Criteria__c c : [
            SELECT Id, EUR_JB_Template__r.Name, EUR_JB_Template__r.Id, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_PRS_Outlet_Type__c, EUR_CRM_PRS_Seg_Aspect_IL__c, EUR_CRM_PRS_Seg_Aspect_VP__c, EUR_JB_Template__c 
            FROM EUR_CRM_JB_Template_Criteria__c
            WHERE EUR_JB_Template__r.RecordType.DeveloperName = :template.RecordType.DeveloperName 
            AND EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Region__c = :regionId]) {
                criterias.put(
                    c.EUR_CRM_PRS_Seg_Aspect_IL__c + ':' + c.EUR_CRM_PRS_Seg_Aspect_VP__c + ':' + c.EUR_CRM_PRS_Group_Outlet_Type__c + ':' + (c.EUR_CRM_PRS_Outlet_Type__c == null ? '' : c.EUR_CRM_PRS_Outlet_Type__c), 
                    c
                );
                if(templatesId.add(c.EUR_JB_Template__r.Id)) {
                    
                    Legend l = new Legend();
                    l.templateId = c.EUR_JB_Template__r.Id;
                    l.name = String.valueOf(colorIndex);
                    legends.put(c.EUR_JB_Template__r.Id, l);

                    colorIndex = colorIndex + 1;
                }
            }
        
        for(EUR_CRM_PRS_Seg_Aspect__c il : ILS) {
            for(EUR_CRM_PRS_Seg_Aspect__c vp : VPS) {
                for(EUR_CRM_PRS_Group_Outlet_Type__c got: GOTS) {

                    //We load only one region
                    if(got.EUR_CRM_Region__c == regionId) {
                        //Outlet is not mandatory
                        if(got.EUR_CRM_PRS_Outlet_Type__r.size() == 0) {
                            EUR_CRM_JB_Template_Criteria__c c = criterias.get(il.Id + ':' + vp.Id + ':' + got.id + ':' + '');
                            Criteria sc = initCriteria(legends, c, il.Id, il.EUR_CRM_Name__c, vp.Id, vp.EUR_CRM_Name__c, got.Id, got.EUR_CRM_PRS_Group_Outlet_Name__c, '', '');
                            data.criterias.add(sc);
                        } else {
                            for(EUR_CRM_PRS_Outlet_Type__c ot : got.EUR_CRM_PRS_Outlet_Type__r) {
                                EUR_CRM_JB_Template_Criteria__c c = criterias.get(il.Id + ':' + vp.Id + ':' + got.id + ':' + ot.Id);
                                Criteria sc = initCriteria(legends, c, il.Id, il.EUR_CRM_Name__c, vp.Id, vp.EUR_CRM_Name__c, got.Id, got.EUR_CRM_PRS_Group_Outlet_Name__c, ot.Id, ot.EUR_CRM_PRS_Outlet_Type_Name__c);
                                data.criterias.add(sc);
                            }
                        }
                        
                    }
                }
            }
        }

        return data;
    }

    private static Criteria initCriteria(Map<Id, Legend> legends, EUR_CRM_JB_Template_Criteria__c c, Id ILId, String ILName, Id VPId, String VPName, Id gotId, String gotName, String otId, String otName) {
        Criteria sc = new Criteria();
        sc.IL_id = ILId;
        sc.IL_name = ILName;

        sc.VP_id = VPId;
        sc.VP_name = VPName;

        sc.GOT_id = gotId;
        sc.GOT_name = gotName;

        sc.OT_id = (otId == null ? '' : otId);
        sc.OT_name = (otName == null ? '' : otName);

        sc.templateId = '';
        sc.templateName = '';
        sc.templateLetter = '';
        sc.templateCriteriaId = '';
        sc.css = '';
        sc.found = false;

        
        if(c != null) {
            sc.templateId = c.EUR_JB_Template__r.Id;
            sc.templateName = c.EUR_JB_Template__r.Name;
            sc.templateCriteriaId = c.Id;
            sc.found = true;
            Legend l = legends.get(c.EUR_JB_Template__r.Id);
            sc.templateLetter = String.valueOf(l.name);
            sc.css = 'background-color:' + l.getColor() + ' !important;';

        }

        return sc;
    }
    private static String getRecordTypeMap(String recordType, String key) {
        System.debug(recordType);
        List<EUR_CRM_Record_Type_Map__mdt> rtm = [SELECT Id, EUR_CRM_Key__c, EUR_CRM_Value__c
            FROM EUR_CRM_Record_Type_Map__mdt
            WHERE 
            EUR_CRM_Is_Active__c = true AND 
            EUR_CRM_Variable_name__c = :key
            AND EUR_CRM_Key__c = :recordType
        ];

        if(rtm.size() == 1) {
            return rtm[0].EUR_CRM_Value__c;
        }

        return null;
    }
    

    @AuraEnabled
    public static List<Picklist> getTemplates(Id templateId) {
        EUR_CRM_JB_Template__c template = getTpl(templateId);
        
        System.debug('CRITERIA getTemplates');

        List<Picklist> options = new List<Picklist>();

        List<EUR_CRM_JB_Template__c> templates = [
            SELECT Id, Name 
            FROM EUR_CRM_JB_Template__c 
            WHERE RecordType.DeveloperName LIKE :template.RecordType.DeveloperName
        ];

        System.debug('Template found: ' + templates.size());

        for(EUR_CRM_JB_Template__c t : templates) {
            Picklist opt = new Picklist();
            opt.label = t.Name;
            opt.value = t.Id;
            options.add(opt);
        }
        

        return options;
    }

    @AuraEnabled(cacheable=false)
    public static void saveTemplateCriterias(String criterias_str, Id templateId) {
        List<Criteria> criterias = (List<Criteria>) JSON.deserialize(criterias_str, List<Criteria>.class);
        EUR_CRM_JB_Template__c template = getTpl(templateId);
        
        String rtCriteria = getRecordTypeMap(template.RecordType.DeveloperName, 'TPLC_CRITERIA');
        System.debug('The criterias to update:');
        System.debug(criterias);
        List<EUR_CRM_JB_Template_Criteria__c> sfCriterias = new List<EUR_CRM_JB_Template_Criteria__c>();
        for(Criteria c : criterias) {
            //OT can be empty
            if(c.GOT_id == null /*|| c.OT_id == null*/ || c.VP_id == null || c.IL_id == null || templateId == null) {
                throw new AuraHandledException('Empty criteria received:' + JSON.serialize(c));
            }
            EUR_CRM_JB_Template_Criteria__c sfC = new EUR_CRM_JB_Template_Criteria__c();
            sfC.EUR_CRM_PRS_Group_Outlet_Type__c = c.GOT_id;
            if(c.OT_id != null && c.OT_id != '') {
                sfC.EUR_CRM_PRS_Outlet_Type__c = c.OT_id;
            } else {
                sfC.EUR_CRM_PRS_Outlet_Type__c = null;
            }
            
            sfC.EUR_CRM_PRS_Seg_Aspect_VP__c = c.VP_id;
            sfC.EUR_CRM_PRS_Seg_Aspect_IL__c = c.IL_id;
            sfC.EUR_JB_Template__c = templateId;
            sfc.EUR_JB_Active__c = true;
            sfC.RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template_Criteria__c.getRecordTypeInfosByDeveloperName().get(rtCriteria).getRecordTypeId();
            if(c.templateCriteriaId != null && c.templateCriteriaId != '') {
                sfC.Id = c.templateCriteriaId;
            }
            sfCriterias.add(sfC);
        }
        //System.debug('Salesforce criteria');
        //System.debug(sfCriterias);

        upsert sfCriterias;


        System.debug('After');
        System.debug(sfCriterias);
    }
    public with sharing class Data {
        @AuraEnabled public boolean hasAllRequiredMetadata;

        @AuraEnabled public List<Criteria> criterias;

        @AuraEnabled public List<Picklist> regions;

        public Data() {
            this.hasAllRequiredMetadata = false;
            this.criterias = new List<Criteria>();
            this.regions = new List<Picklist>();
        }
    }
    
    public with sharing class Criteria {
        @AuraEnabled public String IL_id;
        @AuraEnabled public String IL_name;

        @AuraEnabled public String VP_id;
        @AuraEnabled public String VP_name;

        @AuraEnabled public String GOT_id;
        @AuraEnabled public String GOT_name;

        @AuraEnabled public String OT_id;
        @AuraEnabled public String OT_name;

        @AuraEnabled public String templateCriteriaId;
        @AuraEnabled public String templateId;
        @AuraEnabled public String templateName;
        @AuraEnabled public String templateLetter;
        @AuraEnabled public String css;
        @AuraEnabled public boolean found;
    }
    public with Sharing class Legend {
        public String templateId;
        public String name;

        public String getColor() {
            String color = '';
            Integer ind = Integer.valueOf(this.name);
            //If it needs more than the defined color then we assign it randomly
            if(ind >= colors.size()) {
                String letters = '0123456789ABCDEF';
                
                for (Integer i = 0; i < 6; i++) {
                    Double randomValue = Math.random() * 16;
                    Double indexRandom = Math.floor(randomValue);
                    color += letters.mid(indexRandom.intValue(), 1);
                }
                colors.add(color);
                color = '#' + color;
            } else {
                color = '#' + colors[ind];
            }
            
            return color;
        }
    }
    

    public with sharing class Picklist {
        @AuraEnabled public String label {get;set;}

        @AuraEnabled public String value {get;set;}
    }

    
}