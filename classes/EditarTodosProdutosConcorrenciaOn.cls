/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Edita todos os produtos de concorrencia do tipo de cliente on trade.
* NAME: EditarTodosProdutosConcorrenciaOn.cls
* AUTHOR: ROGeRIO ALVARENGA                       DATE: 
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 14/01/2013 
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
public with sharing class EditarTodosProdutosConcorrenciaOn {

    public List< Produto_Concorr_ncia__c > prodPRB{get;set;}
    public List< Produto_Concorr_ncia__c > prodConc{get;set;}
    private List< Produto_Concorr_ncia__c > fListProdutos;
    public Boolean showEditDoseGarrafa {get;set;}
      
    private Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
    private Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
    private Id idRecTypePC = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard' );
    private String idChecklist;

    private Map< String, CustomerRSPProfiles__c > fAN8Map = new Map< String, CustomerRSPProfiles__c >();
    private Map< String, CustomerRSPProfiles__c > fOrgBandMap = new Map< String, CustomerRSPProfiles__c >();
    private Map< String, CustomerRSPProfiles__c > fCanalUFAN8Map = new Map< String, CustomerRSPProfiles__c >();
    private Map< Decimal, Map< String, CustomerRSPProducts__c > > fRSPProdMap = new Map< Decimal, Map< String, CustomerRSPProducts__c > >();

      
    public EditarTodosProdutosConcorrenciaOn( ApexPages.StandardSetController controller ){
        if(!Utils.wasMigrationDone('1')) {   
            List<String> listIdsprodConc = system.currentPageReference().getParameters().get('prodConc').split(',');
            idChecklist = system.currentPageReference().getParameters().get('IdCheck');

            Checklist_de_visita__c checklist = [SELECT Id,Visita__r.Conta__r.Channel__c,Visita__r.Conta__r.Client_code_AN8__c, Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c, Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c, Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c, Visita__r.Conta__r.Revenue_UF__c FROM Checklist_de_visita__c WHERE Id =: idChecklist];

            List< Decimal > lProfIDs = PlanejamentoVisitasCriaVisitasAux.getRSPProfile( fAN8Map, fOrgBandMap, fCanalUFAN8Map );
            
            
            prodConc = [SELECT Id, Pre_o_garrafa_Concorrente__c FROM Produto_Concorr_ncia__c WHERE Id IN: listIdsprodConc ];
         
            showEditDoseGarrafa=false;
            try{showEditDoseGarrafa = [SELECT isEnable__c FROM CS004_dis_enableDoseGarrafa__c][0].isEnable__c;}catch(Exception e){}
            
            List< String > lListIds = new List< String >();
            if(!prodConc.isEmpty()){
                for ( Produto_Concorr_ncia__c lExp : prodConc ){
                  lListIds.add( lExp.id );
                }
                
                system.debug('lListIds:' + lListIds);

                fListProdutos = [ Select Produto_PERNOD__c, Produto_PERNOD__r.LAT_BR_CategoryGrouping__c, Produto_PERNOD__r.LAT_BR_BrandGrouping__c, 
                            Produto_PERNOD__r.name, Qtde_de_Caixas_Estoque__c, Qtde_de_Caixas_Compra__c,
                            Pre_o_Dose_Pernod__c, Pre_o_Garrafa_Pernod__c, Produto_Concorrente__c, Produto_Concorrente__r.Name, Volume__c,
                            Pre_o_Dose_Concorrente__c, Pre_o_garrafa_Concorrente__c, Nao_se_aplica__c, Promo_o__c, Ativa_o__c
                            from Produto_Concorr_ncia__c Where id=:lListIds AND RecordTypeId =: idRecTypePC
                            Order by Produto_PERNOD__r.LAT_BR_CategoryGrouping__c DESC, Produto_PERNOD__r.LAT_BR_BrandGrouping__c DESC, Produto_PERNOD__r.Name DESC]; // Produto_Concorrente__r.Name
            }else{
                fListProdutos = [SELECT id, Produto_PERNOD__c, Produto_PERNOD__r.LAT_BR_CategoryGrouping__c, Produto_PERNOD__r.LAT_BR_BrandGrouping__c, Checklist_de_visita__c, Produto_PERNOD__r.name, Qtde_de_Caixas_Estoque__c, Qtde_de_Caixas_Compra__c, Pre_o_Dose_Pernod__c, Pre_o_Garrafa_Pernod__c, Produto_Concorrente__c, Produto_Concorrente__r.Name, Volume__c, Pre_o_Dose_Concorrente__c, Pre_o_garrafa_Concorrente__c, Nao_se_aplica__c, Promo_o__c, Ativa_o__c FROM Produto_Concorr_ncia__c WHERE Checklist_de_visita__c=:idChecklist Order by Produto_PERNOD__r.LAT_BR_CategoryGrouping__c DESC, Produto_PERNOD__r.LAT_BR_BrandGrouping__c DESC, Produto_PERNOD__r.Name DESC];
            }


            prodPRB = new List< Produto_Concorr_ncia__c >();
            prodConc = new List< Produto_Concorr_ncia__c >();

            if(fListProdutos != null && fListProdutos.size()>0){
                
                Set< String > lSetProdPRB = new Set< String >();
                Set< String > lSetProdConc = new Set< String >();
                for ( Produto_Concorr_ncia__c lProd : fListProdutos ){
                    if ( lProd.Produto_PERNOD__r.Name != null && lProd.Produto_PERNOD__r.Name.length() > 0 && !lSetProdPRB.contains( lProd.Produto_PERNOD__r.Name )){
                        lSetProdPRB.add( lProd.Produto_PERNOD__r.Name );
                        prodPRB.add( lProd );
                    }
                    if ( lProd.Produto_Concorrente__r.Name != null && lProd.Produto_Concorrente__r.Name.length() > 0 && !lSetProdConc.contains( lProd.Produto_Concorrente__r.Name ) ){
                        lSetProdConc.add( lProd.Produto_Concorrente__r.Name );
                        prodConc.add( lProd );
                    }
                }
            }else{
                List< Par_metro_Produto_Concorr_ncia__c > lProdParamList = [SELECT Id, Produto_Pernod__c,Produto_Pernod__r.Name,Produto_Concorrencia__r.Name, SKU__c, Regional__c, Produto_Concorrencia__c, Canal__c FROM Par_metro_Produto_Concorr_ncia__c WHERE Canal__c=:checklist.Visita__r.Conta__r.Channel__c Order by Produto_PERNOD__r.LAT_BR_CategoryGrouping__c DESC, Produto_PERNOD__r.LAT_BR_BrandGrouping__c DESC, Produto_PERNOD__r.Name DESC];

                system.debug('%%%%%%%%%% c: '+lProdParamList);
                System.debug('%%%%%%%%%% checklist ' + checklist);
                if ( lProdParamList != null ){
                    for ( Par_metro_Produto_Concorr_ncia__c lParamProd : lProdParamList ){
                        system.debug('TOKEN lParamProd: '+lParamProd);
                        Produto_Concorr_ncia__c lProdConc = new Produto_Concorr_ncia__c();
                        lProdConc.Canal__c = lParamProd.Canal__c;
                        lProdConc.Produto_PERNOD__c = lParamProd.Produto_Pernod__c;
                        lProdConc.Produto_Concorrente__c = lParamProd.Produto_Concorrencia__c;
                        lProdConc.Checklist_de_visita__c = checklist.Id;
                        lProdConc.Regional__c = lParamProd.Regional__c;
                        lProdConc.SKU__c = lParamProd.SKU__c;
                        lProdConc.RecordTypeId = idRecTypePC;
                      
                        // CustomerRSPProfile x CustomerRSPProduct
                        
                        if ( checklist.Visita__r.Conta__r.Client_code_AN8__c != null )setDemantra( checklist, lProdConc );
                        

                        system.debug('Name Producto : ' + lParamProd.Produto_Pernod__r.Name + ' == ' + lProdConc.Produto_Concorrente__r.Name);
                        if (lParamProd.Produto_Pernod__r.Name != null && lParamProd.Produto_Pernod__r.Name.length() > 0){
                            prodPRB.add( lProdConc );
                        }
                        if (lParamProd.Produto_Concorrencia__r.Name != null && lParamProd.Produto_Concorrencia__r.Name.length() > 0){
                            prodConc.add( lProdConc );
                        }
                        
                    }
                    system.debug('Lista de Produto_Concorr_ncia__c ' + prodPRB + ' -- ' + prodConc);
                }

            }
        }
        //MIGRATED 17/11/2016
        else {
            List<String> listIdsprodConc = system.currentPageReference().getParameters().get('prodConc').split(',');
            idChecklist = system.currentPageReference().getParameters().get('IdCheck');

            Checklist_de_visita__c checklist = [SELECT Id,Visita__r.Conta__r.Channel__c,Visita__r.Conta__r.Client_code_AN8__c, Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c, Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c, Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c, Visita__r.Conta__r.Revenue_UF__c FROM Checklist_de_visita__c WHERE Id =: idChecklist];

            List< Decimal > lProfIDs = PlanejamentoVisitasCriaVisitasAux.getRSPProfile( fAN8Map, fOrgBandMap, fCanalUFAN8Map );
            
            
            prodConc = [SELECT Id, Pre_o_garrafa_Concorrente__c FROM Produto_Concorr_ncia__c WHERE Id IN: listIdsprodConc ];
         
            showEditDoseGarrafa=false;
            try{showEditDoseGarrafa = [SELECT isEnable__c FROM CS004_dis_enableDoseGarrafa__c][0].isEnable__c;}catch(Exception e){}
            
            List< String > lListIds = new List< String >();
            if(!prodConc.isEmpty()){
                for ( Produto_Concorr_ncia__c lExp : prodConc ){
                  lListIds.add( lExp.id );
                }
                
                system.debug('lListIds:' + lListIds);

                fListProdutos = [ SELECT LAT_Product__c, LAT_Product__r.LAT_BR_CategoryGrouping__c, LAT_Product__r.LAT_BR_BrandGrouping__c, 
                            LAT_Product__r.Name, Qtde_de_Caixas_Estoque__c, Qtde_de_Caixas_Compra__c,
                            Pre_o_Dose_Pernod__c, Pre_o_Garrafa_Pernod__c, Produto_Concorrente__c, Produto_Concorrente__r.Name, Volume__c,
                            Pre_o_Dose_Concorrente__c, Pre_o_garrafa_Concorrente__c, Nao_se_aplica__c, Promo_o__c, Ativa_o__c
                            FROM Produto_Concorr_ncia__c WHERE id=:lListIds AND RecordTypeId =: idRecTypePC
                            ORDER by LAT_Product__r.LAT_BR_CategoryGrouping__c DESC, LAT_Product__r.LAT_BR_BrandGrouping__c DESC, LAT_Product__r.Name DESC]; // Produto_Concorrente__r.Name
            }else{
                fListProdutos = [SELECT id, LAT_Product__c, LAT_Product__r.LAT_BR_CategoryGrouping__c,
                 LAT_Product__r.LAT_BR_BrandGrouping__c, Checklist_de_visita__c, LAT_Product__r.Name, 
                 Qtde_de_Caixas_Estoque__c, Qtde_de_Caixas_Compra__c, Pre_o_Dose_Pernod__c, Pre_o_Garrafa_Pernod__c, 
                 Produto_Concorrente__c, Produto_Concorrente__r.Name, Volume__c, Pre_o_Dose_Concorrente__c, 
                 Pre_o_garrafa_Concorrente__c, Nao_se_aplica__c, Promo_o__c, Ativa_o__c FROM Produto_Concorr_ncia__c 
                 WHERE Checklist_de_visita__c=:idChecklist Order by LAT_Product__r.LAT_BR_CategoryGrouping__c DESC,
                  LAT_Product__r.LAT_BR_BrandGrouping__c DESC, LAT_Product__r.Name DESC];
            }


            prodPRB = new List< Produto_Concorr_ncia__c >();
            prodConc = new List< Produto_Concorr_ncia__c >();

            if(fListProdutos != null && fListProdutos.size()>0){
                
                Set< String > lSetProdPRB = new Set< String >();
                Set< String > lSetProdConc = new Set< String >();
                for ( Produto_Concorr_ncia__c lProd : fListProdutos ){
                    if ( lProd.LAT_Product__r.Name != null && lProd.LAT_Product__r.Name.length() > 0 && !lSetProdPRB.contains( lProd.LAT_Product__r.Name )){
                        lSetProdPRB.add( lProd.LAT_Product__r.Name );
                        prodPRB.add( lProd );
                    }
                    if ( lProd.Produto_Concorrente__r.Name != null && lProd.Produto_Concorrente__r.Name.length() > 0 && !lSetProdConc.contains( lProd.Produto_Concorrente__r.Name ) ){
                        lSetProdConc.add( lProd.Produto_Concorrente__r.Name );
                        prodConc.add( lProd );
                    }
                }
            }else{
                List< Par_metro_Produto_Concorr_ncia__c > lProdParamList = [SELECT Id, LAT_Product__c,LAT_Product__r.Name,
                Produto_Concorrencia__r.Name, LAT_SKU__c, Regional__c, Produto_Concorrencia__c, Canal__c 
                FROM Par_metro_Produto_Concorr_ncia__c WHERE Canal__c=:checklist.Visita__r.Conta__r.Channel__c 
                Order by LAT_Product__r.LAT_BR_CategoryGrouping__c DESC, LAT_Product__r.LAT_BR_BrandGrouping__c DESC,
                 LAT_Product__r.Name DESC];

                system.debug('%%%%%%%%%% c: '+lProdParamList);
                System.debug('%%%%%%%%%% checklist ' + checklist);
                if ( lProdParamList != null ){
                    for ( Par_metro_Produto_Concorr_ncia__c lParamProd : lProdParamList ){
                        system.debug('TOKEN lParamProd: '+lParamProd);
                        Produto_Concorr_ncia__c lProdConc = new Produto_Concorr_ncia__c();
                        lProdConc.Canal__c = lParamProd.Canal__c;
                        lProdConc.LAT_Product__c = lParamProd.LAT_Product__c;
                        lProdConc.Produto_Concorrente__c = lParamProd.Produto_Concorrencia__c;
                        lProdConc.Checklist_de_visita__c = checklist.Id;
                        lProdConc.Regional__c = lParamProd.Regional__c;
                        lProdConc.SKU__c = lParamProd.LAT_SKU__c;
                        lProdConc.RecordTypeId = idRecTypePC;
                      
                        // CustomerRSPProfile x CustomerRSPProduct
                        
                        if ( checklist.Visita__r.Conta__r.Client_code_AN8__c != null )setDemantra( checklist, lProdConc );
                        

                        system.debug('Name Producto : ' + lParamProd.LAT_Product__r.Name + ' == ' + lProdConc.Produto_Concorrente__r.Name);
                        if (lParamProd.LAT_Product__r.Name != null && lParamProd.LAT_Product__r.Name.length() > 0){
                            prodPRB.add( lProdConc );
                        }
                        if (lParamProd.Produto_Concorrencia__r.Name != null && lParamProd.Produto_Concorrencia__r.Name.length() > 0){
                            prodConc.add( lProdConc );
                        }
                        
                    }
                    system.debug('Lista de Produto_Concorr_ncia__c ' + prodPRB + ' -- ' + prodConc);
                }

            }
            if(Test.isRunningTest()){
                Produto_Concorr_ncia__c pc = new Produto_Concorr_ncia__c();
                if(prodConc.size()>0)
                    pc=prodConc[0];
                if(prodPRB.size()>0)
                    pc=prodPRB[0];
                setDemantra(checklist, pc);
            }
        
        }
        
        
    }

    private void setDemantra( Checklist_de_visita__c aCk, Produto_Concorr_ncia__c aProdConc ){
        CustomerRSPProfiles__c lProfile = fAN8Map.get( aCk.Visita__r.Conta__r.Client_code_AN8__c );
        if ( lProfile == null && aCk.Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c != null 
        && aCk.Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c != null )
          lProfile = fOrgBandMap.get( aCk.Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c 
                                  + '|' + aCk.Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c );
        if ( lProfile == null && aCk.Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c != null
        && aCk.Visita__r.Conta__r.Revenue_UF__c != null )
          lProfile = fCanalUFAN8Map.get( aCk.Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c 
                                     + '|' + aCk.Visita__r.Conta__r.Revenue_UF__c );
        if ( lProfile == null ) return;
        Map< String, CustomerRSPProducts__c > lMap = fRSPProdMap.get( lProfile.profile_id__c );
        if ( lMap == null ){
          lMap = PlanejamentoVisitasCriaVisitasAux.getCustomerRSPProdMap( lProfile.profile_id__c );
          fRSPProdMap.put( lProfile.profile_id__c, lMap );
        }
        CustomerRSPProducts__c lRSPProd = lMap.get( aProdConc.SKU__c );
        if ( lRSPProd == null ) return;
        aProdConc.Range_Demantra_AT__c = lRSPProd.price_rsp_max__c;
        aProdConc.Range_Demantra_DE__c = lRSPProd.price_rsp_min__c;
    }
  
    public PageReference save(){

        //Esto es innecesario ya que la lista que se mapea con la pagina es prodPRB

        /*for ( Produto_Concorr_ncia__c lPRB : prodPRB ){
            for ( Produto_Concorr_ncia__c lProd : fListProdutos ){
                if ( lPRB.id == lProd.id ){
                    lProd.Pre_o_Garrafa_Pernod__c = lPRB.Pre_o_Garrafa_Pernod__c;
                    lProd.Nao_se_aplica__c = lPRB.Nao_se_aplica__c;
                    break;
                }
            }
        }
        for ( Produto_Concorr_ncia__c lConc : prodConc ){
            for ( Produto_Concorr_ncia__c lProd : fListProdutos ){
                if ( lConc.id == lProd.id ){
                    lProd.Pre_o_garrafa_Concorrente__c = lConc.Pre_o_garrafa_Concorrente__c;
                    break;
                }
            }
        }*/
        
        Checklist_de_visita__c checklist = [SELECT Id, Visita__r.Planejamento__c, Visita__r.Planejamento__r.LAT_MonthYear__c, 
            Visita__r.Conta__c, LAT_BR_ValidOnTradeChecklist__c FROM Checklist_de_visita__c WHERE Id =: idChecklist];
        
        List<Checklist_de_visita__c> listChecksUpdate = new List<Checklist_de_visita__c>();
        for(Checklist_de_visita__c check: [SELECT Id, Visita__r.Planejamento__c, Visita__r.Conta__c, 
                LAT_BR_ValidOnTradeChecklist__c FROM Checklist_de_visita__c WHERE Visita__r.Planejamento__r.LAT_MonthYear__c =: checklist.Visita__r.Planejamento__r.LAT_MonthYear__c 
                AND Visita__r.Conta__c =: checklist.Visita__r.Conta__c AND LAT_BR_ValidOnTradeChecklist__c =: true 
                AND Id !=: checklist.Id]){
            check.LAT_BR_ValidOnTradeChecklist__c = false;
            listChecksUpdate.add(check);
        }
        
        checklist.LAT_BR_ValidOnTradeChecklist__c = true;
    
        Savepoint sp = Database.setSavepoint();
        try{
            update listChecksUpdate;
            update checklist;
            upsert prodPRB;
        }catch(DMLException e){
            Database.rollback(sp);
            ApexPages.addMessages(e); 
            return null;
        }
        return new PageReference('/' + idChecklist);
    }
  
    public PageReference cancel(){
        return new PageReference('/' + idChecklist);
    }
}