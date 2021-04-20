<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Pedido_com_erro_de_envio_ao_JDE</fullName>
        <description>Pedido com erro de envio ao JDE</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Pedido_com_erro_no_envio_ao_JDE</template>
    </alerts>
    <fieldUpdates>
        <fullName>Atualiza_cif_fob</fullName>
        <field>LAT_Freight__c</field>
        <literalValue>FOB</literalValue>
        <name>Atualiza CIF/FOB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_flag_integra_o</fullName>
        <field>LAT_Integration__c</field>
        <literalValue>0</literalValue>
        <name>Atualiza flag - integração</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_tipo_de_registro</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Nova_oportunidade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza tipo de registro</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_tipo_de_registro_bloqueado</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Bloqueia_alteracao</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza tipo de registro bloqueado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_tipo_de_registro_cab_bloqueado</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Bloqueia_alteracao_do_cabecalho</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza tipo de registro cab bloqueado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Cancela_item</fullName>
        <field>LAT_CancellationApproved__c</field>
        <literalValue>1</literalValue>
        <name>Cancela item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copia_data_entr_calc_para_data_entrega</fullName>
        <field>LAT_DTDelivery__c</field>
        <formula>LAT_EstimatedDeliveryDate__c</formula>
        <name>Copia data entr calc.para data entrega</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_UpdateStage</fullName>
        <description>Updates stage to Approved</description>
        <field>LAT_StageName__c</field>
        <literalValue>Approved</literalValue>
        <name>LAT_AR_UpdateStage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_EDIEnAprobacao</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>EDI Em Aprovação</literalValue>
        <name>LAT BR EDI En Aprobacao</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_EDIOrderApproved</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>EDI Order Approved</literalValue>
        <name>LAT BR EDI Order Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_EDIOrderRejected</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>EDI Order Rejected</literalValue>
        <name>LAT BR EDI Order Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_ClientPaymentPeriodUpdat</fullName>
        <field>LAT_MX_ClientPaymentPeriod__c</field>
        <formula>LAT_Account__r.Payment_Condition__r.Name</formula>
        <name>LAT_MX_OPP_ClientPaymentPeriodUpdat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_LastTotalAmountSentToJDEUpd</fullName>
        <description>Updates the field &apos;Last Total Amount Sent To JDE&apos;</description>
        <field>LAT_MX_LastTotalAmountSentToJDE__c</field>
        <formula>LAT_MX_AmountWithTaxes__c</formula>
        <name>LAT_MX_OPP_LastTotalAmountSentToJDEUpd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_OrderPaymentPeriodUpdat</fullName>
        <description>Since WFR are executed randomly, this FU checks for the LAT_MX_ClientPaymentPeriod__c, which is updated by the WFR LAT_MX_OPP_WF02_ClientPaymentPeriodUpdate. If that field hasn&apos;t been updated by the time this WFR runs, this will use the original UDC value</description>
        <field>LAT_MX_OrderPaymentPeriod__c</field>
        <formula>IF(NOT(ISBLANK(LAT_MX_OrderPaymentPeriodReference__c)), 
LAT_MX_OrderPaymentPeriodReference__r.Name, 
IF(ISBLANK(LAT_MX_ClientPaymentPeriod__c), 
LAT_Account__r.Payment_Condition__r.Name,
LAT_MX_ClientPaymentPeriod__c))</formula>
        <name>LAT_MX_OPP_OrderPaymentPeriodUpdat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_OrderPaymentPeriodUpdate</fullName>
        <field>LAT_MX_OrderPaymentPeriod__c</field>
        <formula>LAT_MX_OrderPaymentPeriodReference__r.Name</formula>
        <name>LAT_MX_OPP_OrderPaymentPeriodUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_PaymentPeriodApprovedUpdate</fullName>
        <field>LAT_MX_PaymentPeriodApproved__c</field>
        <literalValue>0</literalValue>
        <name>LAT_MX_OPP_PaymentPeriodApprovedUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_PaymentPeriodApprovedUpdate2</fullName>
        <description>Updates &apos;Payment period approved?&apos; to true.</description>
        <field>LAT_MX_PaymentPeriodApproved__c</field>
        <literalValue>1</literalValue>
        <name>LAT_MX_OPP_PaymentPeriodApprovedUpdate2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_StageNameUpdate</fullName>
        <description>Updates StageName to &apos;Approval rejected&apos;.</description>
        <field>LAT_StageName__c</field>
        <literalValue>Approval rejected</literalValue>
        <name>LAT_MX_OPP_StageNameUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_StageNameUpdateApproved</fullName>
        <description>Updates StageName to &apos;Pedido enviado para o JDE&apos;.</description>
        <field>LAT_StageName__c</field>
        <literalValue>Pedido enviado para o JDE</literalValue>
        <name>LAT_MX_OPP_StageNameUpdateApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_UpdatePaymentPeriodAppro</fullName>
        <field>LAT_MX_PaymentPeriodApproved__c</field>
        <literalValue>0</literalValue>
        <name>LAT_MX_OPP_UpdatePaymentPeriodAppro</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OPP_UpdatesName</fullName>
        <field>Name</field>
        <formula>LAT_ClientCodeAN8__c + &apos;-&apos; + LAT_MX_OrderNumberCRM__c</formula>
        <name>LAT_MX_OPP_UpdatesName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_OPPFlexApproved</fullName>
        <field>LAT_FlexApproved__c</field>
        <literalValue>1</literalValue>
        <name>OPP Flex Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_OPPStatusUpdateFlexApproved</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>Mobile Order</literalValue>
        <name>OPP Status Update Flex Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_OPPStatusUpdateFlexRejected</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>Pedido Reprovado</literalValue>
        <name>OPP Status Update Flex Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_OPP_StageApproved_UY</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>Pedido Ofrecido aprobado</literalValue>
        <name>LAT_OPP_StageApproved_UY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_OPP_WF01_OrderKeyUpdate</fullName>
        <field>LAT_JDEOrderKey__c</field>
        <formula>TEXT(LAT_Country__c)+&apos;-&apos;+LEFT(TEXT(LAT_Type__c), 2)+&apos;-&apos;+LAT_NROrderJDE__c+&apos;-&apos;+LAT_CompanyCode__c</formula>
        <name>LAT_OPP_WF01_OrderKeyUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_composicao_de_preco</fullName>
        <field>LAT_FormatField__c</field>
        <name>Limpa composição de preço</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_integracao_retorno_JDE</fullName>
        <field>LAT_JDEIntegrationReturn__c</field>
        <name>Limpa integração retorno JDE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OPP_SetTypeToSF_AR</fullName>
        <description>Set Type to SF if Account.Business_Unit__r.CodDefUsuario__c=&apos;09&apos; and Account RT is UY</description>
        <field>LAT_Type__c</field>
        <literalValue>SF - Border Order</literalValue>
        <name>OPP_SetTypeToSF_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OPP_SetTypeToSO_AR</fullName>
        <description>Set Type to SF if Account.Business_Unit__r.CodDefUsuario__c=&apos;10&apos; and Account RT is UY</description>
        <field>LAT_Type__c</field>
        <literalValue>SO - Standard Order</literalValue>
        <name>OPP_SetTypeToSO_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OPP_StageApproved_AR</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>Pedido con descuento aprobado</literalValue>
        <name>OPP_StageApproved_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OPP_StageNew_AR</fullName>
        <field>LAT_StageName__c</field>
        <literalValue>Novo pedido</literalValue>
        <name>OPP_StageNew_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OPP_type_BR</fullName>
        <description>changes the opportunity type to SO - Standard Order</description>
        <field>LAT_Type__c</field>
        <literalValue>SO - Standard Order</literalValue>
        <name>OPP_type_BR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Bloqueia pedido</fullName>
        <actions>
            <name>Atualiza_tipo_de_registro_bloqueado</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_StageName__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_StageName__c</field>
            <operation>notEqual</operation>
            <value>Novo pedido,Mobile Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Bloqueia alteração,Bloqueia alteração do cabeçalho,Nova oportunidade</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CIF%2FFOB cliente</fullName>
        <actions>
            <name>Atualiza_cif_fob</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(RecordType.DeveloperName=&apos;Nova_oportunidade&apos;  ||RecordType.DeveloperName=&apos;Bloqueia_alteracao_do_cabecalho&apos;  ||RecordType.DeveloperName=&apos;Bloqueia_alteracao&apos;) &amp;&amp;   ISPICKVAL(LAT_Account__r.Freight_Type__c, &quot;FOB&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Grava false integração</fullName>
        <actions>
            <name>Atualiza_flag_integra_o</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_Integration__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Bloqueia alteração,Bloqueia alteração do cabeçalho,Nova oportunidade</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Iguala Data de entrega  e calculada</fullName>
        <actions>
            <name>Copia_data_entr_calc_para_data_entrega</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_DTDelivery__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_EstimatedDeliveryDate__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Bloqueia alteração,Bloqueia alteração do cabeçalho,Nova oportunidade</value>
        </criteriaItems>
        <description>Se a data de entrega estiver vazia, quando o campo DATA CALCULADA for preenchido, copia o contéudo da data de entrega.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OPP_WF01_NameUpdate</fullName>
        <actions>
            <name>LAT_MX_OPP_UpdatesName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates field Name when a new record is ceated and when it&apos;s edited.</description>
        <formula>(RecordType.DeveloperName=&apos;LAT_MX_OPP_HeaderBlocked&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_NewOrder&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_OrderBlocked&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OPP_WF02_ClientPaymentPeriodUpdate</fullName>
        <actions>
            <name>LAT_MX_OPP_ClientPaymentPeriodUpdat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates field &apos;Client payment period&apos; when a new record is created.</description>
        <formula>(RecordType.DeveloperName=&apos;LAT_MX_OPP_HeaderBlocked&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_NewOrder&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_OrderBlocked&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OPP_WF03_OrderPaymentPeriodUpdate1</fullName>
        <actions>
            <name>LAT_MX_OPP_OrderPaymentPeriodUpdat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates field &apos;Order payment period&apos; when a new record is created.</description>
        <formula>(RecordType.DeveloperName=&apos;LAT_MX_OPP_HeaderBlocked&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_NewOrder&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_OrderBlocked&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OPP_WF04_OrderPaymentPeriodUpdate2</fullName>
        <actions>
            <name>LAT_MX_OPP_OrderPaymentPeriodUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LAT_MX_OPP_PaymentPeriodApprovedUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates field &apos;Order payment period&apos; when a new record is created.</description>
        <formula>(RecordType.DeveloperName=&apos;LAT_MX_OPP_HeaderBlocked&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_NewOrder&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_OrderBlocked&apos;) &amp;&amp; ISCHANGED(LAT_MX_OrderPaymentPeriodReference__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OPP_WF05_UpdatePaymentPeriodApproved</fullName>
        <actions>
            <name>LAT_MX_OPP_UpdatePaymentPeriodAppro</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates to false the field &apos;Payment period approved?&apos; when fields &apos;Amount with taxes&apos; and &apos;Last Total Amount Sent To JDE&apos; are different.</description>
        <formula>(RecordType.DeveloperName=&apos;LAT_MX_OPP_HeaderBlocked&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_NewOrder&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_OrderBlocked&apos;) &amp;&amp; (LAT_MX_AmountWithTaxes__c != LAT_MX_LastTotalAmountSentToJDE__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OPP_WF06_OrderWithItemsInBackoder</fullName>
        <actions>
            <name>LAT_MX_OPP_ItemsInBackOrder</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>(RecordType.DeveloperName=&apos;LAT_MX_OPP_HeaderBlocked&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_NewOrder&apos; ||  RecordType.DeveloperName=&apos;LAT_MX_OPP_OrderBlocked&apos;) &amp;&amp; LAT_MX_BackorderItems__c = true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LAT_MX_OPP_ItemsInBackOrderMoreThan10Days</name>
                <type>Task</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LAT_OPP_WF01_OrderKeyUpdate</fullName>
        <actions>
            <name>LAT_OPP_WF01_OrderKeyUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(LAT_Country__c)) &amp;&amp; NOT(ISPICKVAL(LAT_Type__c,&apos;&apos;)) &amp;&amp; NOT(ISBLANK(LAT_NROrderJDE__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Limpa campos internos JDE</fullName>
        <actions>
            <name>Limpa_composicao_de_preco</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Limpa_integracao_retorno_JDE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(RecordType.DeveloperName=&apos;Nova_oportunidade&apos; ||RecordType.DeveloperName=&apos;Bloqueia_alteracao_do_cabecalho&apos; ||RecordType.DeveloperName=&apos;Bloqueia_alteracao&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WF01_CleanJDEFields_AR</fullName>
        <actions>
            <name>Limpa_composicao_de_preco</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Limpa_integracao_retorno_JDE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>1 - New Order ARG,2 - New Order URU,3 - Header Blocked ARG,4 - Header Blocked URU,5 - Order Blocked ARG,6 - Order Blocked URU</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WF02_CopyDeliveryDate_AR</fullName>
        <actions>
            <name>Copia_data_entr_calc_para_data_entrega</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_DTDelivery__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_EstimatedDeliveryDate__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>1 - New Order ARG,2 - New Order URU,3 - Header Blocked ARG,4 - Header Blocked URU,5 - Order Blocked ARG,6 - Order Blocked URU</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WF04_OrderWithItemsInBackoder_AR</fullName>
        <actions>
            <name>OPP_ItemsInBackOrder_AR</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_BackorderItemExistsCountry__c</field>
            <operation>equals</operation>
            <value>5</value>
        </criteriaItems>
        <description>When an order has at least one item in backorder a task is created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>OPP_ItemsInBackOrderMoreThan10Days_AR</name>
                <type>Task</type>
            </actions>
            <offsetFromField>LAT_Opportunity__c.LAT_ItemsLastModifiedDate__c</offsetFromField>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>OPP_WF05_SetIntegrationToFalse_AR</fullName>
        <actions>
            <name>Atualiza_flag_integra_o</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_Integration__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>1 - New Order ARG,2 - New Order URU,3 - Header Blocked ARG,4 - Header Blocked URU,5 - Order Blocked ARG,6 - Order Blocked URU</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WF06_SetType_BR</fullName>
        <actions>
            <name>OPP_type_BR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Nova oportunidade</value>
        </criteriaItems>
        <description>Forces all opportunities from Brasil to type SO - Standard Order</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WF07_SetTypeToSF_AR</fullName>
        <actions>
            <name>OPP_SetTypeToSF_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Account.Business_Unit_AR__r.CodDefUsuario__c = &apos;09&apos; and Account RT is from UY and UDC RT is from UY, updates Opportunity.Type</description>
        <formula>AND(LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c=&apos;09&apos;,  LAT_Account__r.Business_Unit_AR__r.RecordType.DeveloperName = &apos;Standard_UY&apos;,  OR( LAT_Account__r.RecordType.DeveloperName = &apos;ACC_2_OffTrade_URU&apos;,  LAT_Account__r.RecordType.DeveloperName = &apos;ACC_4_OnTrade_URU&apos;),  BEGINS(TEXT(LAT_Type__c), &apos;SO&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WF08_SetTypeToSO_AR</fullName>
        <actions>
            <name>OPP_SetTypeToSO_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Account.Business_Unit_AR__r.CodDefUsuario__c = &apos;10&apos; and Account RT is from UY and UDC RT is from UY, updates Opportunity.Type</description>
        <formula>AND(LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c=&apos;10&apos;, LAT_Account__r.Business_Unit_AR__r.RecordType.DeveloperName = &apos;Standard_UY&apos;, OR( LAT_Account__r.RecordType.DeveloperName = &apos;ACC_2_OffTrade_URU&apos;, LAT_Account__r.RecordType.DeveloperName = &apos;ACC_4_OnTrade_URU&apos;),  BEGINS(TEXT(LAT_Type__c), &apos;SF&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Pedido com item em back order</fullName>
        <actions>
            <name>Itens_em_back_order</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.LAT_BackorderItemExists__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Bloqueia alteração,Bloqueia alteração do cabeçalho,Nova oportunidade</value>
        </criteriaItems>
        <description>Quando um item entra em backorder (idenficado por campo Item em back order) aciona criação de atividade de checagem com cliente se ainda deseja receber o produto.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Itens_em_back_order_a_mais_de_10_dias</name>
                <type>Task</type>
            </actions>
            <offsetFromField>LAT_Opportunity__c.LAT_ItemsLastModifiedDate__c</offsetFromField>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Aprovacao_de_pedido_rejeitada</fullName>
        <assignedToType>owner</assignedToType>
        <description>A solicitação de aprovação do pedido, relacionado acima, foi rejeitada durante o processo de aprovação.</description>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Concluído</status>
        <subject>Aprovação de pedido rejeitada</subject>
    </tasks>
    <tasks>
        <fullName>Cancelamento_de_item_pedido_aprovado</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sua solicitação de cancelamento de item/pedido foi aprovada pela Administração de vendas. Para concluir o cancelamento, pressione o botão &quot;Enviar Pedido para JDE&quot;</description>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Concluído</status>
        <subject>Cancelamento de item/pedido aprovado</subject>
    </tasks>
    <tasks>
        <fullName>Itens_do_pedido_fora_da_data_de_entrega</fullName>
        <assignedToType>owner</assignedToType>
        <description>A data de entrega deste pedido informada ao cliente não poderá ser cumprida devido a nova data calculada pelo sistema, de acordo com o calendário PERNOD.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Itens do pedido fora da data de entrega</subject>
    </tasks>
    <tasks>
        <fullName>Itens_em_back_order</fullName>
        <assignedToType>creator</assignedToType>
        <description>Existem itens neste pedido em back order. Favor entrar em contato com o cliente e verificar se ainda deseja receber o(s) produto(s).</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Itens em back order</subject>
    </tasks>
    <tasks>
        <fullName>Itens_em_back_order_a_mais_de_10_dias</fullName>
        <assignedToType>creator</assignedToType>
        <description>Existem itens neste pedido em back order a mais de 10 dias sem alteração. Favor entrar em contato com o cliente e verificar se ainda deseja receber o produto.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Itens em back order a mais de 10 dias</subject>
    </tasks>
    <tasks>
        <fullName>LAT_MX_OPP_ItemsInBackOrder</fullName>
        <assignedToType>owner</assignedToType>
        <description>Existen ítems en este pedido en estado de Back Order. Por favor, entrar en contacto con el cliente y verificar si todavía desea recibir el(los) producto(s).</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>LAT_MX_OPP_ItemsInBackOrder</subject>
    </tasks>
    <tasks>
        <fullName>LAT_MX_OPP_ItemsInBackOrderMoreThan10Days</fullName>
        <assignedToType>owner</assignedToType>
        <description>Existen ítems en este pedido que tienen más de 10 días en estado de Back Order. Por favor, entrar en contacto con el cliente y verificar si todavía desea recibir el(los) producto(s).</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>LAT_MX_OPP_ItemsInBackOrderMoreThan10Days</subject>
    </tasks>
    <tasks>
        <fullName>OPP_ItemsInBackOrderMoreThan10Days_AR</fullName>
        <assignedToType>creator</assignedToType>
        <description>Existen ítems en este pedido que tienen más de 10 días en estado de Back Order. Por favor, entrar en contacto con el cliente y verificar si todavía desea recibir el(los) producto(s)</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>OPP_ItemsInBackOrderMoreThan10Days_AR</subject>
    </tasks>
    <tasks>
        <fullName>OPP_ItemsInBackOrder_AR</fullName>
        <assignedToType>creator</assignedToType>
        <description>Existen ítems en este pedido en estado de Back Order. Por favor, entrar en contacto con el cliente y verificar si todavía desea recibir el(los) producto(s)</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>OPP_ItemsInBackOrder_AR</subject>
    </tasks>
    <tasks>
        <fullName>OPP_OrderWithRetencionCodeInJDE_AR</fullName>
        <assignedToType>creator</assignedToType>
        <description>Existe un pedido con códigos de retención, por favor revise el detalle para más información</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>OPP_OrderWithRetencionCodeInJDE_AR</subject>
    </tasks>
    <tasks>
        <fullName>Pedido_aprovado</fullName>
        <assignedToType>owner</assignedToType>
        <description>O pedido com restrição de crédito, relacionado acima, foi aprovado por todas as alçadas e pode ser enviado novamente ao JDE.</description>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Concluído</status>
        <subject>Pedido aprovado</subject>
    </tasks>
    <tasks>
        <fullName>Prazo_de_entrega_nao_sera_cumprido</fullName>
        <assignedToType>owner</assignedToType>
        <description>Entrar em contato com o cliente avisando que a data prevista para a entrega, inicialmente acordada no pedido, não será cumprida.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Prazo de entrega não será cumprido</subject>
    </tasks>
    <tasks>
        <fullName>Solicitacao_de_cancelamento_rejeitada</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sua solicitação de cancelamento de pedido foi rejeitada pela Administração de Vendas. Para visualizar os detalhes selecione o link com o nome do pedido acima.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Concluído</status>
        <subject>Solicitação de cancelamento rejeitada</subject>
    </tasks>
</Workflow>
