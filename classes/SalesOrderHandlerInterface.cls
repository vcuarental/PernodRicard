/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* 
* NAME: SalesOrderHandlerInterface.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 15/11/2016
*
********************************************************************************/
global class SalesOrderHandlerInterface {
  
  private static final String CONST_INSERT = 'I';
  private static final String CONST_CANCEL = 'C';
  private static final String CONST_UPDATE = 'U';
  
  @future (callout=true)
  Webservice static void SalesOrderInterfaceFuture( String idSalesforce ){
    SalesOrderInterface(idSalesforce);
  }
  
  @future (callout=true)
  Webservice static void LAT_SalesOrderInterfaceFuture( String idSalesforce ){
    LAT_SalesOrderInterface(idSalesforce);
  }
  
  public static boolean isProcessing {get; set;}
  
  Webservice static String SalesOrderInterface( String idSalesforce ){
    Opportunity opp = null;
    String debugStr = '';
    String debugItem = '';
    Set< Id > setRecTypeOpp = new Set< Id >();
    setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'Bloqueia_alteracao' ) );
    setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'Bloqueia_alteracao_do_cabecalho' ) );
    setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'Nova_oportunidade' ) );
    
    List< Opportunity > oppL = [ SELECT id,ownerId,Integracao__c, LAT_Enviado_a_JDE__c,account.Regional__c,account.Sub_Channel__c,account.Sub_Channel_Rating__c,account.Customer_Flag__c, CD_Action__c, Owner.C_digo_JDE__c, DT_delivery__c, Account.Business_Unit__c,
                        Freight__c, DS_Message1__c, DS_Message2__c, CloseDate, Account.Client_code_AN8__c, CreatedDate, 
                        type, NR_order_JDE__c, CD_order_status__c, NR_customer_order__c, Origem_do_pedido__c, RecordTypeId, 
                        Quantidade_total_de_caixas__c, Cancelar_pedido__c, StageName
                        FROM Opportunity WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];
                          
    if ( oppL.size() == 0 ) return 'Pedido (id:' + idSalesforce + ') não encontrado';
    
    opp = oppL[ 0 ];

    
    if ( opp.Origem_do_pedido__c != 'CRM' && opp.Origem_do_pedido__c != 'APP' && opp.StageName != 'Mobile Order' ) return 'Apenas pedidos de origem CRM são passíveis de envio para o JDE';
    
    //Nao enviar pedido sem itens para o JDE - 24/07/2013 - inicio
    if (opp.Quantidade_total_de_caixas__c == 0) { 
      opp.LAT_errorMessage__c = 'Pedido sem Itens não pode ser Enviado para o JDE.';
      update opp;
      return 'Pedido sem Itens não pode ser Enviado para o JDE.'; 
    }
    //Nao enviar pedido sem itens para o JDE - 24/07/2013 - fim
    
    String lRecType = RecordTypeForTest.getRecType( 'Opportunity','Bloqueia_alteracao' );
    if ( opp.RecordTypeId == lRecType ) return 'Pedido bloqueado para envio para o JDE';

    

    
    SalesOrderHandlerTypes.SalesOrderHeaderRequestType header = new SalesOrderHandlerTypes.SalesOrderHeaderRequestType();
    header.salesman = opp.Owner.C_digo_JDE__c;
    header.orderNumberForeign = String.valueOf( opp.id );
    header.customerCode = Integer.valueOf( opp.Account.Client_code_AN8__c );
    header.customerShippingCode = header.customerCode;
    header.customerBuyOrder = opp.NR_customer_order__c;
    header.note1 = opp.DS_Message1__c;
    header.note2 = opp.DS_Message2__c;
    
    // Ajuste para resolver a conversão GMT da camada SOA
    Date lTempDate;
    if ( opp.DT_delivery__c != null )
      lTempDate = opp.DT_delivery__c;
    else
      lTempDate = opp.CloseDate;
    
    if(lTempDate < date.today()){
        lTempDate = date.today();
    }
    
    header.promisedDate = Datetime.newinstance( lTempDate.year(), lTempDate.month(), lTempDate.day(), 14, 01,02 );
    
    if ( opp.Freight__c != null && opp.Freight__c.equalsIgnoreCase( 'FOB' ) )
      header.freightType = 'F';
    else
      header.freightType = '';
    header.orderRequestDate = opp.CreatedDate;
    header.orderRequestTime = 0;
    header.invoiceDate = Date.today();
    header.businessUnit = Utils.getCodeFromUDC( opp.Account.Business_Unit__c );
    string oppType = opp.Type;
    if (oppType != null && oppType.length() > 2) {
        header.orderType = oppType.substring(0,2);
    } else {
        header.orderType = 'SO';
    }
    if ( opp.NR_order_JDE__c != null && opp.NR_order_JDE__c != '' )
      header.orderNumber = Long.valueOf( opp.NR_order_JDE__c );
    if ( opp.CD_order_status__c != null && opp.CD_order_status__c != 0 )
      header.orderStatus = Integer.valueOf( opp.CD_order_status__c );
      
    boolean hasUpdate = false;
    Map< String, OpportunityLineItem > mapItems = new Map< String, OpportunityLineItem >();
    
    List< OpportunityLineItem > listaItens = [ SELECT CD_Action__c, LAT_SkuText__c, LAT_PaymentCondition__c, 
        NR_order_line__c, QT_Bonus__c, Quantity, LAT_UnitCode__c, LAT_PercentualBonus__c, 
        pc_discount__c, cd_line_status__c FROM OpportunityLineItem 
        WHERE OpportunityId =: idSalesforce AND cd_line_status__c<>'999' ];
        
    List< SalesOrderHandlerTypes.SalesOrderItemRequestType > items = new List< SalesOrderHandlerTypes.SalesOrderItemRequestType >();
    
    
    for ( OpportunityLineItem oppItem : listaItens )
    {
      SalesOrderHandlerTypes.SalesOrderItemRequestType item = new SalesOrderHandlerTypes.SalesOrderItemRequestType();
      if ( oppItem.CD_Action__c == null  || !oppItem.CD_Action__c.equalsIgnoreCase( CONST_CANCEL ) )
      {
        if ( oppItem.NR_order_line__c == null || oppItem.NR_order_line__c.equalsIgnoreCase( '' ) )
          item.actionCode = CONST_INSERT;
        else
          item.actionCode = '';
      }
      else
        item.actionCode = oppItem.CD_Action__c;
      if ( oppItem.CD_Action__c != null )
        hasUpdate = hasUpdate || ( oppItem.CD_Action__c.equalsIgnoreCase( CONST_CANCEL ) || oppItem.CD_Action__c.equalsIgnoreCase( CONST_INSERT ) );
      if ( oppItem.NR_order_line__c != null )
        item.lineNumber = Integer.valueOf( oppItem.NR_order_line__c );
      if (oppItem.LAT_SkuText__c != null && oppItem.LAT_SkuText__c.trim().length() > 0) {
        item.sku = oppItem.LAT_SkuText__c;
      }
      item.paymentTerm = oppItem.LAT_PaymentCondition__c;
      item.billedTotalQuantity = oppItem.Quantity;
      item.bonusQuantity = Integer.valueOf( oppItem.QT_Bonus__c );
      item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
      if ( oppItem.LAT_UnitCode__c == null || oppItem.LAT_UnitCode__c.equalsIgnoreCase( '' ) )
        item.bonusUnit = 'CA';
      else
        item.bonusUnit = String.valueOf( oppItem.LAT_UnitCode__c );
      item.salesUOM = item.bonusUnit;
      if (oppItem.pc_discount__c != null) {
        item.percentualDiscount = oppItem.pc_discount__c;
      } else {
        item.percentualDiscount = 0;
      }
      
      item.orderLineStatus = oppItem.cd_line_status__c;
      
      // Campos obligatorios de items
      item.promisedDate = header.promisedDate;
      item.estimatedDeliveryDate = header.promisedDate;
      item.logisticsPromisedDate = header.promisedDate;
      item.realDeliveryDate = header.promisedDate;
      
      items.add( item );
      mapItems.put( oppItem.LAT_SkuText__c, oppItem );
      
      debugItem += ' |start item, lineNumber: ' + item.lineNumber + ' - sku: ' + item.sku + ' - salesUOM: ' + item.salesUOM + ' - paymentTerm: ' + item.paymentTerm + ' - billedTotalQuantity: ' + item.billedTotalQuantity
      + ' - bonusQuantity: ' + item.bonusQuantity + ' - bonusPercentual: ' + item.bonusPercentual + ' - bonusUnit: ' + item.bonusUnit + ' - percentualDiscount: ' + item.percentualDiscount + ' - orderLineStatus: ' + item.orderLineStatus + ' - actionCode: ' + item.actionCode;
    }
    
    if ( opp.CD_Action__c == null || ( !opp.CD_Action__c.equalsIgnoreCase( CONST_CANCEL ) && hasUpdate ) )
    {
      if ( opp.NR_order_JDE__c != null && Long.valueOf(opp.NR_order_JDE__c) > 0)header.actionCode = CONST_UPDATE;
      else header.actionCode = CONST_INSERT;
    }
    else
      header.actionCode = opp.CD_Action__c;
      
    // Campos obligatorios de header
    header.purchaseOrderUntil = header.promisedDate;
      
    debugStr = 'Salesman: ' + header.salesman+' - orderNumberForeign: ' + header.orderNumberForeign + ' - customerCode: '+header.customerCode+' - customerShippingCode: ' + header.customerShippingCode
    + ' - customerBuyOrder: ' + header.customerBuyOrder + ' - note1: '+header.note1 + ' - note2: '+header.note2 + ' - promisedDate: '+header.promisedDate + ' - freightType: '+header.freightType
    + ' - orderRequestDate: ' + header.orderRequestDate + ' - orderRequestTime: ' + header.orderRequestTime + ' - invoiceDate: ' + header.invoiceDate + ' - businessUnit: ' + header.businessUnit
    + ' - orderType: ' + header.orderType + ' - orderNumber: ' + header.orderNumber + ' - orderStatus: ' + header.orderStatus + ' - actionCode: ' + header.actionCode;
    
    SalesOrderHandler.execute_pt request = new SalesOrderHandler.execute_pt();
    request.timeout_x = 120000;
    SalesOrderHandlerTypes.SalesOrderHandlerResponseType response;
    integer lResponseCode = 0;
    try
    {
      lResponseCode = request.execute( getConnectionParameter(), header, items );
    }
    catch ( Exception e )
    {
      opp.Integracao_Retorno_JDE__c = debugStr + '=' + debugItem+'='+e.getMessage();
      opp.StageName = 'Pedido com erro no JDE';
      opp.Integracao__c = true;
      opp.LAT_errorMessage__c = 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';
      update opp;
      return 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';
    }

    if ( lResponseCode == 0 )
    {
      opp.StageName = opp.StageName == 'Mobile Order' ? 'Moblie Order Sent To JDE' : 'Pedido enviado para o JDE';
      opp.RecordTypeId = RecordTypeForTest.getRecType( 'Opportunity','Bloqueia_alteracao' );
    }
    else {
      opp.StageName = 'Pedido com erro no JDE';
      opp.LAT_errorMessage__c = 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';
      return 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';

    }
     
    //Actualiza la closeDate con la fecha del primer envio
    if(!opp.LAT_Enviado_a_JDE__c && opp.nr_order_jde__c != '' && opp.nr_order_jde__c != null)opp.LAT_Enviado_a_JDE__c = true;
        
    if(!opp.LAT_Enviado_a_JDE__c){
       opp.CloseDate = Date.today();
       opp.LAT_Enviado_a_JDE__c = true;
    }
    opp.Integracao__c = true;
    update opp;
    return '';
    
  }
  //MIGRATED 15/11/2016
  Webservice static String LAT_SalesOrderInterface( String idSalesforce ){
    LAT_Opportunity__c opp = null;
    String debugStr = '';
    String debugItem = '';
    Set< Id > setRecTypeOpp = new Set< Id >();
    setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao' ) );
    setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho' ) );
    setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'Nova_oportunidade' ) );
    
    List< LAT_Opportunity__c > oppL = [ SELECT id, OwnerId,LAT_Integration__c, LAT_SentToJDE__c, LAT_Account__r.Regional__c, LAT_Account__r.Sub_Channel__c, LAT_Account__r.Sub_Channel_Rating__c,
     LAT_Account__r.Customer_Flag__c, LAT_CDAction__c, LAT_Account__r.Owner.C_digo_JDE__c, LAT_DTDelivery__c, LAT_Account__r.Business_Unit__c,
                        LAT_Freight__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_CloseDate__c, LAT_Account__r.Client_code_AN8__c, CreatedDate, 
                        LAT_Type__c, LAT_NROrderJDE__c, LAT_CDOrderStatus__c, LAT_NRCustomerOrder__c, LAT_OrderOrigin__c, RecordTypeId, 
                        LAT_ItemsTotalQuantity__c, LAT_CancelOrder__c, LAT_StageName__c, LAT_IsFlex__c, LAT_FlexManagerApprove__c, LAT_FlexApproved__c, Aquila_Id__c 
                        FROM LAT_Opportunity__c WHERE Id =: idSalesforce AND RecordTypeId =: setRecTypeOpp limit 1];
                          
    if ( oppL.size() == 0 ) return 'Pedido (id:' + idSalesforce + ') não encontrado';
    
    opp = oppL[ 0 ];

    
    if ( opp.LAT_OrderOrigin__c != 'CRM' && opp.LAT_OrderOrigin__c != 'APP' && opp.LAT_StageName__c != 'Mobile Order' ) return 'Apenas pedidos de origem CRM são passíveis de envio para o JDE';
    
    //Nao enviar pedido sem itens para o JDE - 24/07/2013 - inicio
    if (opp.LAT_ItemsTotalQuantity__c == 0) { 
      opp.LAT_ErrorMessage__c = 'Pedido sem Itens não pode ser Enviado para o JDE.';
      update opp;
      return 'Pedido sem Itens não pode ser Enviado para o JDE.'; 
    }
    //Nao enviar pedido sem itens para o JDE - 24/07/2013 - fim
      
    //Si el pedido es Flexible, fue tiene que ser aprobado al menos por el Manager y no ha sido aprobado aun, se envía a Aprobar.
    System.debug('%%%%%  opp.LAT_IsFlex__c: '+ opp.LAT_IsFlex__c +' || opp.LAT_FlexManagerApprove__c: '+ opp.LAT_FlexManagerApprove__c +' || opp.LAT_FlexApproved__c: '+ opp.LAT_FlexApproved__c);
    if(opp.LAT_IsFlex__c && opp.LAT_FlexManagerApprove__c && !opp.LAT_FlexApproved__c) {
        Approval.ProcessSubmitRequest ap = new Approval.ProcessSubmitRequest();
        ap.setObjectId(opp.Id);
        Approval.ProcessResult result = Approval.process(ap);
        opp.LAT_Integration__c = true;
        opp.LAT_StageName__c = 'Pedido Flex em Aprovação';
        update opp;
        return 'Pedido Flex enviado a Aprovação.';
    }


    String lRecType = RecordTypeForTest.getRecType( 'LAT_Opportunity__c','Bloqueia_alteracao' );
    if ( opp.RecordTypeId == lRecType && !opp.LAT_FlexApproved__c) return 'Pedido bloqueado para envio para o JDE';


    

    
    SalesOrderHandlerTypes.SalesOrderHeaderRequestType header = new SalesOrderHandlerTypes.SalesOrderHeaderRequestType();
    header.salesman = opp.LAT_Account__r.Owner.C_digo_JDE__c;
    header.orderNumberForeign = String.valueOf( opp.id );
    header.customerCode = Integer.valueOf( opp.LAT_Account__r.Client_code_AN8__c );
    header.customerShippingCode = header.customerCode;
    header.customerBuyOrder = opp.LAT_NRCustomerOrder__c;
    header.externalID = opp.Aquila_Id__c;
    System.debug('%%%%% header.externalID: '+ header.externalID);
    header.note1 = opp.LAT_DSMessage1__c;
    header.note2 = opp.LAT_DSMessage2__c;
    
    // Ajuste para resolver a conversão GMT da camada SOA
    Date lTempDate;
    if ( opp.LAT_DTDelivery__c != null )
      lTempDate = opp.LAT_DTDelivery__c;
    else
      lTempDate = opp.LAT_CloseDate__c;
    
    if(lTempDate < date.today()){
        lTempDate = date.today();
    }
    
    header.promisedDate = Datetime.newinstance( lTempDate.year(), lTempDate.month(), lTempDate.day(), 14, 01,02 );
    
    if ( opp.LAT_Freight__c != null && opp.LAT_Freight__c.equalsIgnoreCase( 'FOB' ) )
      header.freightType = 'F';
    else
      header.freightType = '';
    header.orderRequestDate = opp.CreatedDate;
    header.orderRequestTime = 0;
    header.invoiceDate = Date.today();
    header.businessUnit = Utils.getCodeFromUDC( opp.LAT_Account__r.Business_Unit__c );
    string oppType = opp.LAT_Type__c;
    if (oppType != null && oppType.length() > 2) {
        header.orderType = oppType.substring(0,2);
    } else {
        header.orderType = 'SO';
    }
    if ( opp.LAT_NROrderJDE__c != null && opp.LAT_NROrderJDE__c != '' )
      header.orderNumber = Long.valueOf( opp.LAT_NROrderJDE__c );
    if ( opp.LAT_CDOrderStatus__c != null && opp.LAT_CDOrderStatus__c != 0 )
      header.orderStatus = Integer.valueOf( opp.LAT_CDOrderStatus__c );
      
    boolean hasUpdate = false;
    Map< String, LAT_OpportunityLineItem__c > mapItems = new Map< String, LAT_OpportunityLineItem__c >();
    
    List< LAT_OpportunityLineItem__c > listaItens = [ SELECT LAT_CDAction__c, LAT_SkuText__c, LAT_PaymentCondition__c, 
        LAT_NROrderLine__c, LAT_QTBonus__c, LAT_Quantity__c, LAT_UnitCode__c, LAT_PercentualBonus__c, 
        LAT_PcDiscount__c, LAT_CdLineStatus__c, LAT_AR_Discount__c FROM LAT_OpportunityLineItem__c 
        WHERE LAT_Opportunity__c =: idSalesforce AND LAT_CdLineStatus__c<>'999' ];
        
    List< SalesOrderHandlerTypes.SalesOrderItemRequestType > items = new List< SalesOrderHandlerTypes.SalesOrderItemRequestType >();
    
    
    for ( LAT_OpportunityLineItem__c oppItem : listaItens )
    {
      SalesOrderHandlerTypes.SalesOrderItemRequestType item = new SalesOrderHandlerTypes.SalesOrderItemRequestType();
      if ( oppItem.LAT_CDAction__c == null  || !oppItem.LAT_CDAction__c.equalsIgnoreCase( CONST_CANCEL ) )
      {
        if ( oppItem.LAT_NROrderLine__c == null || oppItem.LAT_NROrderLine__c.equalsIgnoreCase( '' ) )
          item.actionCode = CONST_INSERT;
        else
          item.actionCode = '';
      }
      else
        item.actionCode = oppItem.LAT_CDAction__c;
      if ( oppItem.LAT_CDAction__c != null )
        hasUpdate = hasUpdate || ( oppItem.LAT_CDAction__c.equalsIgnoreCase( CONST_CANCEL ) || oppItem.LAT_CDAction__c.equalsIgnoreCase( CONST_INSERT ) );
      if ( oppItem.LAT_NROrderLine__c != null )
        item.lineNumber = Integer.valueOf( oppItem.LAT_NROrderLine__c );
      if (oppItem.LAT_SkuText__c != null && oppItem.LAT_SkuText__c.trim().length() > 0) {
        item.sku = oppItem.LAT_SkuText__c;
      }
      item.paymentTerm = oppItem.LAT_PaymentCondition__c;
      item.billedTotalQuantity = oppItem.LAT_Quantity__c;
      item.bonusQuantity = Integer.valueOf( oppItem.LAT_QTBonus__c );
      item.bonusPercentual = oppItem.LAT_PercentualBonus__c;
      if ( oppItem.LAT_UnitCode__c == null || oppItem.LAT_UnitCode__c.equalsIgnoreCase( '' ) )
        item.bonusUnit = 'CA';
      else
        item.bonusUnit = String.valueOf( oppItem.LAT_UnitCode__c );
      item.salesUOM = item.bonusUnit;
      /*if (oppItem.LAT_PcDiscount__c != null) {
        item.percentualDiscount = oppItem.LAT_PcDiscount__c;
      } else {
        item.percentualDiscount = 0;
      }*/
      if (oppItem.LAT_AR_Discount__c != null) {
        item.percentualDiscount = oppItem.LAT_AR_Discount__c;
      } else {
        item.percentualDiscount = 0;
      }
      item.orderLineStatus = oppItem.LAT_CdLineStatus__c;
      
      // Campos obligatorios de items
      item.promisedDate = header.promisedDate;
      item.estimatedDeliveryDate = header.promisedDate;
      item.logisticsPromisedDate = header.promisedDate;
      item.realDeliveryDate = header.promisedDate;
      
      items.add( item );
      mapItems.put( oppItem.LAT_SkuText__c, oppItem );
      
      debugItem += ' |start item, lineNumber: ' + item.lineNumber + ' - sku: ' + item.sku + ' - salesUOM: ' + item.salesUOM + ' - paymentTerm: ' + item.paymentTerm + ' - billedTotalQuantity: ' + item.billedTotalQuantity
      + ' - bonusQuantity: ' + item.bonusQuantity + ' - bonusPercentual: ' + item.bonusPercentual + ' - bonusUnit: ' + item.bonusUnit + ' - percentualDiscount: ' + item.percentualDiscount + ' - orderLineStatus: ' + item.orderLineStatus + ' - actionCode: ' + item.actionCode;
    }
    
    if ( opp.LAT_CDAction__c == null || ( !opp.LAT_CDAction__c.equalsIgnoreCase( CONST_CANCEL ) && hasUpdate ) )
    {
      if ( opp.LAT_NROrderJDE__c != null && Long.valueOf(opp.LAT_NROrderJDE__c) > 0)header.actionCode = CONST_UPDATE;
      else header.actionCode = CONST_INSERT;
    }
    else
      header.actionCode = opp.LAT_CDAction__c;
      
    // Campos obligatorios de header
    header.purchaseOrderUntil = header.promisedDate;
      
    debugStr = 'Salesman: ' + header.salesman+' - orderNumberForeign: ' + header.orderNumberForeign + ' - customerCode: '+header.customerCode+' - customerShippingCode: ' + header.customerShippingCode
    + ' - customerBuyOrder: ' + header.customerBuyOrder + ' - note1: '+header.note1 + ' - note2: '+header.note2 + ' - promisedDate: '+header.promisedDate + ' - freightType: '+header.freightType
    + ' - orderRequestDate: ' + header.orderRequestDate + ' - orderRequestTime: ' + header.orderRequestTime + ' - invoiceDate: ' + header.invoiceDate + ' - businessUnit: ' + header.businessUnit
    + ' - orderType: ' + header.orderType + ' - orderNumber: ' + header.orderNumber + ' - orderStatus: ' + header.orderStatus + ' - actionCode: ' + header.actionCode;
    
    SalesOrderHandler.execute_pt request = new SalesOrderHandler.execute_pt();
    request.timeout_x = 120000;
    SalesOrderHandlerTypes.SalesOrderHandlerResponseType response;
    integer lResponseCode = 0;
    try
    {
      lResponseCode = request.execute( getConnectionParameter(), header, items );
    }
    catch ( Exception e )
    {
      opp.LAT_JDEIntegrationReturn__c = debugStr + '=' + debugItem+'='+e.getMessage();
      opp.LAT_StageName__c = 'Pedido com erro no JDE';
      opp.LAT_Integration__c = true;
      opp.LAT_ErrorMessage__c = 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';
      update opp;
      return 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';
    }

    if ( lResponseCode == 0 )
    {
      opp.LAT_StageName__c = opp.LAT_StageName__c == 'Mobile Order' ? 'Moblie Order Sent To JDE' : 'Pedido enviado para o JDE';
      opp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Opportunity__c','Bloqueia_alteracao' );
    }
    else {
      opp.LAT_StageName__c = 'Pedido com erro no JDE';
      opp.LAT_ErrorMessage__c = 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';
      return 'Erro inesperado no envio para o JDE. Contate o administrador do sistema';

    }
     
    //Actualiza la closeDate con la fecha del primer envio
    if(!opp.LAT_SentToJDE__c && opp.LAT_NROrderJDE__c != '' && opp.LAT_NROrderJDE__c != null)opp.LAT_SentToJDE__c = true;
        
    if(!opp.LAT_SentToJDE__c){
       opp.LAT_CloseDate__c = Date.today();
       opp.LAT_SentToJDE__c = true;
    }
    opp.LAT_Integration__c = true;
    system.debug('aaaaaa ' + opp);
    update opp;
    return '';
    
  }

  public static SalesOrderHandlerTypes.ClientInfoType getConnectionParameter()
  {
  
        SalesOrderHandlerTypes.ClientInfoType connParms = new SalesOrderHandlerTypes.ClientInfoType();
        /*connParms.country='1';
        connParms.remoteHostIP='salesforce';
        connParms.system_x='';
        connParms.systemUserID='';
        //connParms.time_x=today;*/
        
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
        if(cred!=null){
          connParms.country = cred.Country__c;
          connParms.remoteHostIP = cred.RemoteHostIP__c;
          connParms.system_x = cred.System__c;
          connParms.systemUserID = cred.SystemUserID__c;
          connParms.time_x=Datetime.now();
      }
        return connParms;
     
  }
  
}