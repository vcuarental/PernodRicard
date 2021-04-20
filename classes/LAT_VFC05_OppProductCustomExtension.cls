/*************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_VFP05_OppProductCustomExtension
* Descripcion: extencion de la pagina LAT_VFP05_OppProductCustomExtension
* Fecha: 28/01/2014 
**************************************************************************/

public with sharing class LAT_VFC05_OppProductCustomExtension{

    public List<OpportunityLineItem> listOlis {get; set;}
    public List<Schema.FieldSetMember> lFields {get; set;}
    public Boolean isBR {get; set;}
    
    private Opportunity opp;
    private Set<Id> RtsBR;
    private Set<Id> RtsMX;
        
    public LAT_VFC05_OppProductCustomExtension(ApexPages.StandardController controller){
        
        opp = (Opportunity)controller.getRecord();
        Id oppId = opp.Id;
        
        RtsBR = Global_RecordTypeCache.getRtIdSet('Opportunity', new Set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao'}); 
        RtsMX = Global_RecordTypeCache.getRtIdSet('Opportunity', new Set<String>{'LAT_MX_OPP_NewOrder', 'LAT_MX_OPP_HeaderBlocked', 'LAT_MX_OPP_OrderBlocked'});    
        
        lFields = new List<Schema.FieldSetMember>();
        isBR = false;
        if(RtsBR.contains(opp.RecordTypeId)){
            lFields = SObjectType.OpportunityLineItem.FieldSets.LAT_BR_OppProductCustom.getFields();
            isBR = true;
        }else if(RtsMX.contains(opp.RecordTypeId)){
            lFields = SObjectType.OpportunityLineItem.FieldSets.LAT_MX_OppProductCustom.getFields();
        }
        
        String query = 'SELECT Id ';
        for (Schema.FieldSetMember f : lFields) {
            query += ', ' + f.getFieldPath();
        }
        
        query += ', PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name';
        if(RtsBR.contains(opp.RecordTypeId)){
            query += ' FROM OpportunityLineItem WHERE OpportunityId =: oppId ORDER BY NR_order_line__c, PricebookEntry.Product2.Name';
        }else{
            query += ' FROM OpportunityLineItem WHERE OpportunityId =: oppId ORDER BY NR_Order_Item__c, PricebookEntry.Product2.Name';
        }        
        
        listOlis = DataBase.query(query);
    }

}