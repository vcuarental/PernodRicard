public with sharing class EUR_CRM_Template_Edition {
    public static final String 
        RTM_VAR_Product     = 'TPLL_Product',
        RTM_VAR_RT_Mapping  = 'TPLL_Line',
        BQ_LEVEL            = 'BQ',
        BQS_LEVEL           = 'BQS';
    
    public static final String 
        STATUS_REQUIRED = 'R',
        STATUS_OPTIONAL = 'O',
        STATUS_RECOMMANDED = 'Recommanded',
        STATUS_CONTRACTED = 'Contracted';

    

    

    @AuraEnabled
    public static string cloneTemplateAndLines(String template_id){
        //External ID not retrieved in the select
        List<EUR_CRM_JB_Template__c> template = [
            SELECT Id, Name, CurrencyIsoCode, EUR_CRM_Customer_Taxonomy__c, EUR_CRM_Default__c, EUR_CRM_Module__c, RecordTypeId, EUR_CRM_Segmentation__c
            FROM EUR_CRM_JB_Template__c 
            WHERE id = :template_id
        ];
        if(template.size() == 1) {
            EUR_CRM_JB_Template__c tCloned = template[0].clone(false, true);
            tCloned.Name = tCloned.Name + ' (Cloned)';
            insert tCloned;
            //External ID not retrieved in the select
            List<EUR_CRM_JB_Template_Line__c> linesCloned = new List<EUR_CRM_JB_Template_Line__c>();
            for(EUR_CRM_JB_Template_Line__c line : [
                SELECT Id, EUR_CRM_Activation__c, EUR_CRM_Available__c, EUR_CRM_Back_of_Bar__c, EUR_CRM_Back_of_Bar_Display__c, EUR_JB_Brand_Quality__c, EUR_Brand_Quality_Size__c, EUR_CRM_By_Glass__c, EUR_CRM_Cabinet_Display__c, CurrencyIsoCode, EUR_CRM_Display_Fridge__c, EUR_CRM_Displayed__c, EUR_CRM_Exclusive_SKU__c, EUR_CRM_Facings__c, EUR_CRM_First_Position__c, EUR_CRM_House_Pour__c, EUR_CRM_House_Pour_Picklist__c, EUR_CRM_Listed__c, EUR_CRM_Listing_Status_KAM__c, EUR_CRM_Low_Stock_Guidance__c, EUR_CRM_Mandatory__c, EUR_CRM_On_the_Menu__c, EUR_CRM_Optional__c, EUR_CRM_Oversized_bottles__c, EUR_CRM_POS_Material__c, EUR_CRM_POSM_Visibility__c, EUR_CRM_Premium_Pouring__c, EUR_CRM_Presence__c, EUR_JB_Listing__c, EUR_CRM_Prestige_Pouring__c, EUR_CRM_Price_Promotion__c, EUR_CRM_Promoted_Picklist__c, EUR_CRM_Promoted__c, EUR_CRM_Recommended__c, RecordTypeId, EUR_CRM_Retail_Selling_Price_Recommended__c, EUR_CRM_Seasonal_Listing__c, EUR_CRM_Shelf_Placement__c, EUR_JB_SKU__c, EUR_JB_CRM_Template__c, Name, EUR_CRM_Top_of_Counter__c, EUR_CRM_Value_Added_Promotion__c, EUR_CRM_Visibility__c, EUR_CRM_Visible__c
                FROM EUR_CRM_JB_Template_Line__c 
                WHERE EUR_JB_CRM_Template__c = :template[0].Id
                ]) {
                    EUR_CRM_JB_Template_Line__c lineCloned = line.clone(false, true);
                    lineCloned.EUR_JB_CRM_Template__c = tCloned.Id;
                    linesCloned.add(lineCloned);
                }
                insert linesCloned;

                System.debug('cloned id : ' + tCloned.Id);
                return tCloned.Id;
        } else {
            throw new AuraHandledException('Controlled error: Template not found');
        }

        
    }


    @AuraEnabled(cacheable=true)
    public static List<TemplateLine> getProducts(String template_id) {
        List<TemplateLine> products = new List<TemplateLine>();
        
        EUR_CRM_JB_Template__c template = getTemplate(template_id);
        
        String productInfo = getRTM_Product(template.RecordType.DeveloperName);
        
        String productLevel = productInfo.split(',')[0];
        String rtProduct = productInfo.split(',')[1];

        if(productLevel == BQ_LEVEL) {
            products = loadBQProducts(template_id, rtProduct);
        } else if(productLevel == BQS_LEVEL) {
            products = loadBQSProducts(template_id, rtProduct);
        } else {
            throw new AuraHandledException('Controlled error: Wrong value in Record Type Map (var=TPL_EDIT_RT_PRODUCT)');
        }
            

        return products;
    }

    private static EUR_CRM_JB_Template__c getTemplate(String template_id) {
        List<EUR_CRM_JB_Template__c> template = [
            SELECT Id, RecordType.DeveloperName 
            FROM EUR_CRM_JB_Template__c
            WHERE id = :template_id
        ];

        if(template.size() != 1) {
            throw new AuraHandledException('Controlled error: Template not found');
        }

        return template[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<TemplateLine> getTemplateLines(String template_id) {
        System.debug(template_id);
        
        List<EUR_CRM_JB_Template_Line__c> existingLines = [
            SELECT Id, EUR_JB_Listing__c,
            EUR_JB_Brand_Quality__r.Id, EUR_JB_Brand_Quality__r.Name, EUR_JB_Brand_Quality__r.EUR_CRM_Category__c, 
                    EUR_JB_Brand_Quality__r.EUR_CRM_Brand__r.Name, 
            EUR_Brand_Quality_Size__r.Id, EUR_Brand_Quality_Size__r.Name, EUR_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Category__c, 
                    EUR_Brand_Quality_Size__r.EUR_CRM_Brand__c , EUR_JB_CRM_Template__c
            FROM EUR_CRM_JB_Template_Line__c 
            WHERE EUR_JB_CRM_Template__c = :template_id ORDER BY EUR_Brand_Quality_Size__r.Name, EUR_JB_Brand_Quality__r.Name
        ];

        List<TemplateLine> lines = new List<TemplateLine>();

        for(EUR_CRM_JB_Template_Line__c l : existingLines)  {
            
            
            TemplateLine line = new TemplateLine();
            line.defaultValues();
            line.category = (l.EUR_JB_Brand_Quality__r.EUR_CRM_Category__c == null ? l.EUR_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Category__c : l.EUR_JB_Brand_Quality__r.EUR_CRM_Category__c);
            line.brand = (l.EUR_JB_Brand_Quality__r.EUR_CRM_Brand__r.Name == null ? l.EUR_Brand_Quality_Size__r.EUR_CRM_Brand__c : l.EUR_JB_Brand_Quality__r.EUR_CRM_Brand__r.Name);
        
            line.product            = (l.EUR_Brand_Quality_Size__r.Name == null ? l.EUR_JB_Brand_Quality__r.Name : l.EUR_Brand_Quality_Size__r.Name);
            line.product_id         = (l.EUR_Brand_Quality_Size__r.Id == null ? l.EUR_JB_Brand_Quality__r.Id : l.EUR_Brand_Quality_Size__r.Id);
            line.product_url = '/' + line.product_id;
            line.template_line_id   = l.Id;
            line.template_line_url = '/' + l.Id;
            line.template_id        = l.EUR_JB_CRM_Template__c;
            line.required           = (l.EUR_JB_Listing__c == STATUS_REQUIRED);
            line.optional           = (l.EUR_JB_Listing__c == STATUS_OPTIONAL);
            line.recommanded        = (l.EUR_JB_Listing__c == STATUS_RECOMMANDED);
            line.contracted         = (l.EUR_JB_Listing__c == STATUS_CONTRACTED);
            lines.add(line);
            System.debug(line.product);
            System.debug(l.EUR_JB_Listing__c);
        }

        return lines;
    }


    @AuraEnabled
    public static boolean checkRequiredMetadata(Id templateId){
        EUR_CRM_JB_Template__c template = getTemplate(templateId);

        String level = getRTM_Product(template.RecordType.DeveloperName);
        String lineRTDevName = getRTM_RT_Mapping(template.RecordType.DeveloperName);

        if(level != null && lineRTDevName != null && level.split(',').size() == 2) {
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static TemplateLine changeLineStatus(TemplateLine tplLine, String status){
        status = status.toLowerCase();

        tplLine.defaultValues();
        tplLine.optional = false;
        String newStatus = '';
        if(status == 'required') {
            tplLine.required = true;
            newStatus = STATUS_REQUIRED;
        } else if(status == 'optional') {
            tplLine.optional = true;
            newStatus = STATUS_OPTIONAL;
        } else if(status == 'recommanded') {
            tplLine.recommanded = true;
            newStatus = STATUS_RECOMMANDED;
        } else if(status == 'contracted') {
            tplLine.contracted = true;
            newStatus = STATUS_CONTRACTED;
        } else {
            throw new AuraHandledException('Wrong status (' + status + ') to update ' + tplLine.product);
        }

        List<EUR_CRM_JB_Template_Line__c> lines = [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE id =:tplLine.template_line_id];
        if(lines.size() == 1) {
            lines[0].EUR_JB_Listing__c = newStatus;
            update lines[0];
        } else {
            throw new AuraHandledException('Issue when trying to retrieve the line of the product ' + tplLine.product + ' to update it with the status ' + newStatus);
        }

        return tplLine;
    }
    @AuraEnabled
    public static TemplateLine deleteTemplateLine(TemplateLine tplLine) {
        System.debug(tplLine);
        List<EUR_CRM_JB_Template_Line__c> line = [SELECT Id FROM EUR_CRM_JB_Template_Line__c WHERE id = :tplLine.template_line_id];

        if(line.size() != 1) {
            throw new AuraHandledException('Controlled issue : Could not remove ' + tplLine.product + ' from the template');
        } else {
            delete line[0];
        }
        tplLine.defaultValues();
        tplLine.template_line_id   = null;
        tplLine.template_line_url  = null;
        return tplLine;
    }

    @AuraEnabled
    public static TemplateLine addToTemplate(TemplateLine tplLine) {
        EUR_CRM_JB_Template__c template = getTemplate(tplLine.template_id);

        String level = getRTM_Product(template.RecordType.DeveloperName);
        String lineRTDevName = getRTM_RT_Mapping(template.RecordType.DeveloperName);

        EUR_CRM_JB_Template_Line__c newLine = tplLine.translateToRealObject(level.split(',')[0], lineRTDevName);
        
        insert newLine;

        tplLine.template_line_id = newLine.Id;
        tplLine.template_line_url = '/' + newLine.Id;
        return tplLine;
    }

    /*
    public with sharing class TemplatePicklist {
        @AuraEnabled public String label {get;set;}

        @AuraEnabled public String value {get;set;}
    }*/

    public with sharing class TemplateLine {

        public TemplateLine() {
            this.defaultValues();
        }

        public void defaultValues() {
            this.optional           = true;
            this.required           = false;
            this.contracted         = false;
            this.recommanded        = false;
            this.valueIsInSearchRange    = true;
        }

        @AuraEnabled public String category {get;set;}

        @AuraEnabled public String brand {get;set;}

        @AuraEnabled public String product {get;set;}

        @AuraEnabled public String product_id {get;set;}
        @AuraEnabled public String product_url {get;set;}

        @AuraEnabled public String template_id {get;set;}

        @AuraEnabled public String template_line_id {get;set;}
        @AuraEnabled public String template_line_url {get;set;}

        @AuraEnabled public boolean required {get;set;}

        @AuraEnabled public boolean optional {get;set;}

        @AuraEnabled public boolean recommanded {get;set;}

        @AuraEnabled public boolean contracted {get;set;}

        @AuraEnabled public boolean valueIsInSearchRange{get;set;}

        private String translateToListing() {
            if(this.required == true) {
                return STATUS_REQUIRED;
            } else if(this.recommanded == true) {
                return STATUS_RECOMMANDED;
            } else if(this.contracted == true) {
                return STATUS_CONTRACTED;
            } else if(this.optional == true) {
                return STATUS_OPTIONAL;
            } else {
                throw new AuraHandledException('Presence / Listing should have a value for the product ' + this.product);
            }
        }

        

        public EUR_CRM_JB_Template_Line__c translateToRealObject(String level, String tplLineRtDeveloperName) {
            EUR_CRM_JB_Template_Line__c line = new EUR_CRM_JB_Template_Line__c();
            line.EUR_JB_Listing__c = this.translateToListing();
            
            
            if(level == EUR_CRM_Template_Edition.BQ_LEVEL) {
                line.EUR_JB_Brand_Quality__c = this.product_id;
            } else {
                line.EUR_Brand_Quality_Size__c = this.product_id;
            }
            line.EUR_JB_CRM_Template__c = this.template_id;
            line.RecordTypeId = Schema.SObjectType.EUR_CRM_JB_Template_Line__c.getRecordTypeInfosByDeveloperName().get(tplLineRtDeveloperName).getRecordTypeId();

            return line;
        }
    }

    private static string getRTM_Product(String templateRtDeveloperName) {
        List<EUR_CRM_Record_Type_Map__mdt> rtm = [SELECT Id, EUR_CRM_Key__c, EUR_CRM_Value__c
            FROM EUR_CRM_Record_Type_Map__mdt
            WHERE 
            EUR_CRM_Is_Active__c = true AND 
            EUR_CRM_Variable_name__c = :RTM_VAR_Product
            AND EUR_CRM_Key__c = :templateRtDeveloperName
        ];
        if(rtm.size() != 1) {
            throw new AuraHandledException('Controlled error: Metadata Record Type Map (var=' + RTM_VAR_Product + ') not found for record type ' + templateRtDeveloperName);
        }

        return rtm[0].EUR_CRM_Value__c.toUpperCase();
    }

    private static string getRTM_RT_Mapping(String templateRtDeveloperName) {
        List<EUR_CRM_Record_Type_Map__mdt> rtm = [SELECT Id, EUR_CRM_Key__c, EUR_CRM_Value__c
            FROM EUR_CRM_Record_Type_Map__mdt
            WHERE 
            EUR_CRM_Is_Active__c = true AND 
            EUR_CRM_Variable_name__c = :RTM_VAR_RT_Mapping
            AND EUR_CRM_Key__c = :templateRtDeveloperName
        ];
        if(rtm.size() != 1) {
            throw new AuraHandledException('Controlled error: Metadata Record Type Map (var=' + RTM_VAR_RT_Mapping + ') not found for record type ' + templateRtDeveloperName);
        }

        return rtm[0].EUR_CRM_Value__c;
    }

    private static List<TemplateLine> loadBQProducts(String template_id, String rt) {
        List<TemplateLine> products = new List<TemplateLine>();
        Set<Id> existingProducts = new Set<Id>();
        for(EUR_CRM_JB_Template_Line__c l : [
            SELECT EUR_JB_Brand_Quality__c 
            FROM EUR_CRM_JB_Template_Line__c 
            WHERE EUR_JB_CRM_Template__c = :template_id
        ]) {
            existingProducts.add(l.EUR_JB_Brand_Quality__c);
        }

        for(EUR_CRM_Quality__c bq : [
            SELECT Id, Name, EUR_CRM_Brand__r.Name, EUR_CRM_Category__c 
            FROM EUR_CRM_Quality__c 
            WHERE EUR_CRM_Active__c = true AND Id NOT IN :existingProducts AND RecordType.DeveloperName = :rt 
            ORDER BY EUR_CRM_Category__c, EUR_CRM_Brand__r.Name, Name
        ]) {
            
            
            TemplateLine line = new TemplateLine();
            line.defaultValues();
            line.category = bq.EUR_CRM_Category__c;
            line.brand = bq.EUR_CRM_Brand__r.Name;
            line.product            = bq.Name;
            line.product_id         = bq.Id;
            line.product_url = '/' + bq.Id;
            line.template_id        = template_id;
            products.add(line);
        }
        return products;
    }

    private static List<TemplateLine> loadBQSProducts(String template_id, String rt) {
        List<TemplateLine> products = new List<TemplateLine>();
        Set<Id> existingProducts = new Set<Id>();
        for(EUR_CRM_JB_Template_Line__c l : [
            SELECT EUR_Brand_Quality_Size__c 
            FROM EUR_CRM_JB_Template_Line__c 
            WHERE EUR_JB_CRM_Template__c = :template_id
        ]) {
            existingProducts.add(l.EUR_Brand_Quality_Size__c);
        }

        for(EUR_CRM_Size__c bqs : [
                SELECT Id, Name, EUR_CRM_Brand__c, EUR_CRM_Brand_Quality__r.EUR_CRM_Category__c 
                FROM EUR_CRM_Size__c 
                WHERE EUR_CRM_Active__c = true AND Id NOT IN :existingProducts AND RecordType.DeveloperName = :rt
                ORDER BY EUR_CRM_Brand_Quality__r.EUR_CRM_Category__c, EUR_CRM_Brand__c, Name
            ]) {
            TemplateLine line = new TemplateLine();
            line.defaultValues();
            line.category = bqs.EUR_CRM_Brand_Quality__r.EUR_CRM_Category__c;
            line.brand = bqs.EUR_CRM_Brand__c;
            line.product            = bqs.Name;
            line.product_id         = bqs.Id;
            line.product_url = '/' + bqs.Id;
            line.template_id        = template_id;
            products.add(line);
        }
        return products;
    }

}