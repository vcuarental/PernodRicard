<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACC_ErrorInJDE_AR</fullName>
        <description>ACC_ErrorInJDE_AR</description>
        <protected>false</protected>
        <recipients>
            <recipient>matias.dacostacruz@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ACC_AccountErrorInJDE_AR</template>
    </alerts>
    <alerts>
        <fullName>ACC_ErrorInJDE_UY</fullName>
        <description>ACC_ErrorInJDE_UY</description>
        <protected>false</protected>
        <recipients>
            <recipient>laura.carames@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ACC_AccountErrorInJDE_AR</template>
    </alerts>
    <alerts>
        <fullName>ACC_OwnerApprovalNotification_AR</fullName>
        <description>ACC_OwnerApprovalNotification_AR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ACC_AccountNewRecordApproved_AR</template>
    </alerts>
    <alerts>
        <fullName>ACC_OwnerRejectionNotification_AR</fullName>
        <description>ACC_OwnerRejectionNotification_AR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ACC_AccNewRecordRejected_AR</template>
    </alerts>
    <alerts>
        <fullName>ASI_LUX_Anniversary_Reminder_for_PR_LUX</fullName>
        <description>Anniversary Reminder for PR LUX</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_LUX/ASI_LUX_Le_Cercle_Membership_Anniversary_Reminder</template>
    </alerts>
    <alerts>
        <fullName>ASI_LUX_Birthday_Alert_Email</fullName>
        <description>ASI LUX Birthday Alert Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_LUX/ASI_LUX_Birthday_Reminder</template>
    </alerts>
    <alerts>
        <fullName>ASI_LUX_Birthday_EmailAlert</fullName>
        <description>Birthday Reminder for PR LUX</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_LUX/ASI_LUX_Birthday_Reminder</template>
    </alerts>
    <alerts>
        <fullName>ASI_LUX_Le_Cercle_Membership_Anniversary</fullName>
        <ccEmails>Wilken.Lee@pernod-ricard.com</ccEmails>
        <description>ASI LUX Le Cercle Membership Anniversary</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>ASI_LUX/ASI_LUX_Le_Cercle_Membership_Anniversary_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Adm_Vendas_Aviso_de_confer_ncia_de_cadastro_de_cliente</fullName>
        <description>Adm Vendas Aviso de conferência de cadastro de cliente</description>
        <protected>false</protected>
        <recipients>
            <recipient>Administracao_de_Vendas</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Conferencia_de_novo_cadastro_de_cliente</template>
    </alerts>
    <alerts>
        <fullName>Alerta_para_gerentes</fullName>
        <description>Alerta para gerentes</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Alteracao_de_contrato_Efetivada</template>
    </alerts>
    <alerts>
        <fullName>Avisa_propriet_rio_pedido_maior_que_100_mil</fullName>
        <ccEmails>emailtosalesforce@1mm3bxfx7fcjhqzagx4l1vw29u41p3cc1knjtn4twvf4qnzmof.q-1e16vmac.q.le.sandbox.salesforce.com</ccEmails>
        <description>Avisa proprietário pedido maior que 100 mil</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Acordo_maior_que_10_mil</template>
    </alerts>
    <alerts>
        <fullName>Cadastro_do_cliente_rejeitado</fullName>
        <description>Cadastro do cliente rejeitado</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Novo_cadastro_de_clientes_rejeitado</template>
    </alerts>
    <alerts>
        <fullName>Controladoria_Aviso_de_confer_ncia_de_cadastro_de_cliente</fullName>
        <description>Controladoria Aviso de conferência de cadastro de cliente</description>
        <protected>false</protected>
        <recipients>
            <recipient>Controladoria</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Conferencia_de_novo_cadastro_de_cliente</template>
    </alerts>
    <alerts>
        <fullName>Cred_Cobranca_Aviso_de_confer_ncia_de_cadastro_de_cliente</fullName>
        <description>Cred Cobranca Aviso de conferência de cadastro de cliente</description>
        <protected>false</protected>
        <recipients>
            <recipient>Credito_e_cobran_a</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Conferencia_de_novo_cadastro_de_cliente</template>
    </alerts>
    <alerts>
        <fullName>LAT_BR_ACC_NotifiesComercialPlanning</fullName>
        <description>BR Email to Commercial Planning after a new client is registered</description>
        <protected>false</protected>
        <recipients>
            <recipient>Planejamento_comercial</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LAT_BR_ACC_NotifiesComercialPlanning</template>
    </alerts>
    <alerts>
        <fullName>LAT_MX_ACC_AccountErrorJDEEmailAlert</fullName>
        <description>LAT_MX_ACC_Account Error JDE Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>LAT_MX_JDEIntegrationErrorNotif</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LAT_MX_ACC_AccountErrorJDE</template>
    </alerts>
    <alerts>
        <fullName>LAT_MX_ACC_NewAccRecordCRM</fullName>
        <description>LAT_MX_ACC_New Account Record CRM</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LAT_MX_ACC_NewAccountRecordCRM</template>
    </alerts>
    <alerts>
        <fullName>LAT_MX_Account_OnTradeRejected</fullName>
        <description>Cliente Rechazado</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LAT_MX_Account_OnTradeRejected</template>
    </alerts>
    <alerts>
        <fullName>Novo_cadastro_de_clientes_aprovado</fullName>
        <description>Novo cadastro de clientes aprovado</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Novo_cadastro_de_clientes_aprovado</template>
    </alerts>
    <alerts>
        <fullName>Planej_comercial_Aviso_de_confer_ncia_de_cadastro_de_cliente</fullName>
        <description>Planej comercial Aviso de conferência de cadastro de cliente</description>
        <protected>false</protected>
        <recipients>
            <recipient>Planejamento_comercial</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Conferencia_de_novo_cadastro_de_cliente</template>
    </alerts>
    <fieldUpdates>
        <fullName>ACC_IsInterfaceProcessUpdate_AR</fullName>
        <field>Is_Interface_Process_AR__c</field>
        <literalValue>0</literalValue>
        <name>ACC_IsInterfaceProcessUpdate_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_RatingUpdate1_AR</fullName>
        <description>Updates Rating to &apos;Cliente potencial&apos;</description>
        <field>Rating</field>
        <literalValue>Cliente potencial</literalValue>
        <name>ACC_RatingUpdate1_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_RatingUpdate2_AR</fullName>
        <field>Rating</field>
        <literalValue>Cliente negativado</literalValue>
        <name>ACC_RatingUpdate2_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_RatingUpdate3_AR</fullName>
        <field>Rating</field>
        <literalValue>Cliente</literalValue>
        <name>ACC_RatingUpdate3_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_RatingUpdate4_AR</fullName>
        <field>Rating</field>
        <literalValue>Cliente inativo</literalValue>
        <name>ACC_RatingUpdate4_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_RatingUpdate5_AR</fullName>
        <field>Rating</field>
        <literalValue>Cliente oportunidade</literalValue>
        <name>ACC_RatingUpdate5_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_RevenueUFUpdate_AR</fullName>
        <description>Updates UF to the first or the two first characters of Descricao2 field of UDC record related to field City.</description>
        <field>Revenue_UF__c</field>
        <formula>IF(FIND(&apos;-&apos;,Revenue_City__r.Descricao2__c)=2, LEFT(Revenue_City__r.Descricao2__c,1), IF(FIND(&apos;-&apos;,Revenue_City__r.Descricao2__c)=3,LEFT(Revenue_City__r.Descricao2__c,2),&apos;&apos;))</formula>
        <name>ACC_RevenueUFUpdate_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate1_AR</fullName>
        <description>Updates Status to &apos;En aprobacion - Comercial&apos;</description>
        <field>Status__c</field>
        <literalValue>Em aprovação  - Comercial</literalValue>
        <name>ACC_StatusUpdate1_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate2_AR</fullName>
        <description>Updates Status to &apos;En análisis – Créditos y Cobranzas&apos;</description>
        <field>Status__c</field>
        <literalValue>Em análise - Crédito e Cobrança</literalValue>
        <name>ACC_StatusUpdate2_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate3_AR</fullName>
        <description>Updates Status to &apos;Cliente Denegado&apos;</description>
        <field>Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>ACC_StatusUpdate3_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate4_AR</fullName>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no CRM</literalValue>
        <name>ACC_StatusUpdate4_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate5_AR</fullName>
        <field>Status__c</field>
        <literalValue>Em aprovação - Financeiro</literalValue>
        <name>ACC_StatusUpdate5_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate6_AR</fullName>
        <field>Status__c</field>
        <literalValue>Not approved by Credit and Collections</literalValue>
        <name>ACC_StatusUpdate6_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate7_AR</fullName>
        <field>Status__c</field>
        <literalValue>Directed to be registered In JDE</literalValue>
        <name>ACC_StatusUpdate7_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate8_AR</fullName>
        <field>Status__c</field>
        <literalValue>Inactive Account</literalValue>
        <name>ACC_StatusUpdate8_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_StatusUpdate9_AR</fullName>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no JDE</literalValue>
        <name>ACC_StatusUpdate9_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_UpdateCreditLineTo0_AR</fullName>
        <field>Credit_line__c</field>
        <formula>0</formula>
        <name>ACC_UpdateCreditLineTo0_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_UpdateCreditLineTo1_AR</fullName>
        <field>Credit_line__c</field>
        <formula>1</formula>
        <name>ACC_UpdateCreditLineTo1_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_UpdateNeighbourhood_AR</fullName>
        <description>Update Neighbourhood</description>
        <field>Revenue_Neighbourhood__c</field>
        <formula>Revenue_City__r.Name</formula>
        <name>ACC_UpdateNeighbourhood_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACC_UpdateTriggerRun_AR</fullName>
        <description>Updates TriggerRun to False after the trigger sets it to True.</description>
        <field>TriggerRun__c</field>
        <literalValue>0</literalValue>
        <name>ACC_UpdateTriggerRun_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_BRD_Copy_Home_Phone</fullName>
        <field>PersonHomePhone</field>
        <formula>ASI_BRD_Home_Phone__pc</formula>
        <name>ASI BRD - Copy Home Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_BRD_SG_Convert_SG_LUX_First_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_SG_Account_First_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_BRD_SG_Convert_SG_LUX_First_Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_BRD_SG_Set_English_PreferredLang1</fullName>
        <field>ASI_LUX_Preferred_Language_1__c</field>
        <literalValue>English</literalValue>
        <name>ASI_BRD_SG_Set_English_PreferredLang1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_BRD_Update_OtherBrand1_Engaged</fullName>
        <field>ASI_BRD_OtherBrand1_Engaged__pc</field>
        <literalValue>Yes</literalValue>
        <name>ASI_BRD_Update_OtherBrand1_Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_BRD_Update_OtherBrand2_Engaged</fullName>
        <field>ASI_BRD_OtherBrand2_Engaged__pc</field>
        <literalValue>Yes</literalValue>
        <name>ASI_BRD_Update_OtherBrand2_Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_BRD_Update_OtherBrand3_Engaged</fullName>
        <field>ASI_BRD_OtherBrand3_Engaged__pc</field>
        <literalValue>Yes</literalValue>
        <name>ASI_BRD_Update_OtherBrand3_Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Append_Cust_Num_to_Name</fullName>
        <description>Append ASI_HK_CRM_Customer_Number__c to Name</description>
        <field>Name</field>
        <formula>Name + &quot; (&quot; + ASI_HK_CRM_Customer_Number__c + &quot;)&quot;</formula>
        <name>ASI HK CRM Append Cust Num to Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_Clear_Next_Anniversary_Day</fullName>
        <field>ASI_LUX_Next_Anniversary_Date__pc</field>
        <name>ASI LUX Clear Next Anniversary Day</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_Clear_Next_Birthday</fullName>
        <field>ASI_LUX_Next_Birthday__pc</field>
        <name>ASI LUX Clear Next Birthday</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Check_Le_Cercle_Member</fullName>
        <field>ASI_LUX_Le_Cercle_Member__c</field>
        <literalValue>1</literalValue>
        <name>ASI LUX HK - Check Le Cercle Member</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Set_Le_Cercle_Locked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX HK - Set Le Cercle Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Set_Member_Since_Date</fullName>
        <field>ASI_LUX_LeCercle_Member_Since_Date__c</field>
        <formula>TODAY()</formula>
        <name>ASI LUX HK - Set Member Since Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Set_Submission_Date</fullName>
        <field>ASI_LUX_LeCercle_Submit_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>ASI LUX HK - Set Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Update_Status_to_Approved</fullName>
        <field>ASI_LUX_LeCercle_Member_Appl_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI LUX HK - Update Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Update_Status_to_New</fullName>
        <field>ASI_LUX_LeCercle_Member_Appl_Status__c</field>
        <literalValue>New</literalValue>
        <name>ASI LUX HK - Update Status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Update_Status_to_Rejected</fullName>
        <field>ASI_LUX_LeCercle_Member_Appl_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>ASI LUX HK - Update Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Update_Status_to_Submitted</fullName>
        <description>Updates ASI_LUX_LeCercle_Member_Appl_Status__c to Submitted</description>
        <field>ASI_LUX_LeCercle_Member_Appl_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI LUX HK - Update Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_MY_Set_Le_Cercle_Locked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_MY_Second_Contact_Le_Cercle_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX MY - Set Le Cercle Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_MY_Set_RecordType_First_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_MY_First_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX MY Set RecordType: First Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_MY_Update_Record_2nd_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_MY_Second_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX MY Update Record 2nd Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_REG_Set_RecordType_First_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_Regional_First_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX REG Set RecordType First Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_REG_Update_RecordType_2ndContact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_Regional_Second_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX REG Update RecordType 2ndContact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_Reg_Set_Le_Cercle_Locked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_Regional_Second_Contact_Le_Cercle_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX Reg - Set Le Cercle Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_SG_Set_Le_Cercle_Locked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_SG_Account_Second_Contact_Le_Cercle_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX SG - Set Le Cercle Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_SG_Set_Member_Since_Date</fullName>
        <field>ASI_LUX_LeCercle_Member_Since_Date__c</field>
        <formula>Today()</formula>
        <name>ASI LUX SG - Set Member Since Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_SG_Update_Record_2nd_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_SG_Account_Second_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX SG Update Record 2nd Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_Set_Next_Anniversary_Day</fullName>
        <field>ASI_LUX_Next_Anniversary_Date__pc</field>
        <formula>DATE(
YEAR ( ASI_LUX_LeCercle_Member_Since_Date__c ) + (FLOOR((TODAY() - ASI_LUX_LeCercle_Member_Since_Date__c) / 365)  + 1),
MONTH(ASI_LUX_LeCercle_Member_Since_Date__c),
IF(AND(DAY(ASI_LUX_LeCercle_Member_Since_Date__c) = 29,MONTH(ASI_LUX_LeCercle_Member_Since_Date__c ) = 02) , 28, DAY(ASI_LUX_LeCercle_Member_Since_Date__c)))</formula>
        <name>ASI LUX Set Next Anniversary Day</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_Set_Next_Birthday</fullName>
        <field>ASI_LUX_Next_Birthday__pc</field>
        <formula>IF(MONTH(ASI_LUX_This_Years_Birthday__c) &gt; MONTH(TODAY()),DATE(YEAR(TODAY()),MONTH(ASI_LUX_This_Years_Birthday__c),DAY(ASI_LUX_This_Years_Birthday__c)),
IF(MONTH(ASI_LUX_This_Years_Birthday__c) &lt; MONTH(TODAY()),DATE(YEAR(TODAY())+1,MONTH(ASI_LUX_This_Years_Birthday__c),DAY(ASI_LUX_This_Years_Birthday__c)),
IF(DAY(ASI_LUX_This_Years_Birthday__c) &gt;= (DAY(TODAY())),DATE(YEAR(TODAY()),MONTH(ASI_LUX_This_Years_Birthday__c),DAY(ASI_LUX_This_Years_Birthday__c)),
DATE(YEAR(TODAY())+1,MONTH(ASI_LUX_This_Years_Birthday__c),DAY(ASI_LUX_This_Years_Birthday__c)))))</formula>
        <name>ASI LUX Set Next Birthday</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_Set_RecordType_First_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_HK_First_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX - Set RecordType: First Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_TW_Set_Le_Cercle_Locked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_TW_Second_Contact_Le_Cercle_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX TW - Set Le Cercle Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_TW_Set_RecordType_First_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_TW_First_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX TW Set RecordType: First Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_TW_Update_Record_2nd_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_TW_Second_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX TW Update Record 2nd Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_Update_Record_Type_2nd_Contact</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_Luxury_Account_HK_Second_Contact</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX Update Record Type - 2nd Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_bairro_cobran_a_upper</fullName>
        <field>Billing_Neighbourhood__c</field>
        <formula>UPPER( Billing_Neighbourhood__c )</formula>
        <name>Alt bairro cobrança upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_bairro_entrega_upper</fullName>
        <field>Shipping_Neighbourhood__c</field>
        <formula>UPPER( Shipping_Neighbourhood__c )</formula>
        <name>Alt bairro entrega upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_bairro_faturamento_upper</fullName>
        <field>Revenue_Neighbourhood__c</field>
        <formula>UPPER( Revenue_Neighbourhood__c )</formula>
        <name>Alt bairro faturamento upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_logradouro_cobran_a_upper</fullName>
        <field>Billing_Address__c</field>
        <formula>UPPER( Billing_Address__c )</formula>
        <name>Alt logradouro cobrança upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_logradouro_cobranca_upper</fullName>
        <field>Billing_Address__c</field>
        <formula>upper (Billing_Address__c)</formula>
        <name>Alt logradouro cobrança upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_logradouro_entrega_upper</fullName>
        <field>Shipping_Address__c</field>
        <formula>UPPER( Shipping_Address__c )</formula>
        <name>Alt logradouro entrega upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_logradouro_faturamento_upper</fullName>
        <field>Revenue_Address__c</field>
        <formula>UPPER( Revenue_Address__c )</formula>
        <name>Alt logradouro faturamento upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_nome_fantasia_upper</fullName>
        <field>Name</field>
        <formula>UPPER( Name )</formula>
        <name>Alt nome fantasia upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_razao_social_upper</fullName>
        <field>Corporate_Name__c</field>
        <formula>UPPER( Corporate_Name__c )</formula>
        <name>Alt razao social upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_Checked_over_Comptroller</fullName>
        <field>Checked_over_Comptroller__c</field>
        <literalValue>0</literalValue>
        <name>Altera Checked over Comptroller</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Analise_planj_comercial</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - Planejamento Comercial</literalValue>
        <name>Altera status - Análise planj comercial</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Aprov_cadastro_no_JDE</fullName>
        <field>Status__c</field>
        <literalValue>Aprovado - Aguardando retorno do JDE</literalValue>
        <name>Altera status - Aprov cadastro no JDE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Cadastrado_no_CRM</fullName>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no CRM</literalValue>
        <name>Altera status - Cadastrado no CRM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Em_Analise_CeC</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - Crédito e Cobrança</literalValue>
        <name>Altera status - Em Análise CeC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Em_analise_ADM_Vendas</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - ADM Vendas</literalValue>
        <name>Altera status - Em análise ADM Vendas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Em_analise_Legal</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - Legal</literalValue>
        <name>Altera status - Em análise Legal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Em_aprova_o_financeiro</fullName>
        <field>Status__c</field>
        <literalValue>Em aprovação - Financeiro</literalValue>
        <name>Altera status - Em aprovação financeiro</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Nao_Aprovado</fullName>
        <field>Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>Altera status - Não Aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_em_analise_controladoria</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - Controladoria</literalValue>
        <name>Altera status - Em análise Controladoria</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_classificacao_Cliente</fullName>
        <field>Rating</field>
        <literalValue>Cliente</literalValue>
        <name>Atualiza classificação - Cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_codigo_cidade_faturamento</fullName>
        <field>Revenue_City_Code__c</field>
        <formula>Revenue_City__r.CodDefUsuario__c</formula>
        <name>Atualiza codigo cidade faturamento</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_numero_banco</fullName>
        <field>Bank_number__c</field>
        <formula>Bank__r.CodDefUsuario__c</formula>
        <name>Atualiza número banco</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_numero_do_banco</fullName>
        <field>Bank_number__c</field>
        <formula>Bank__r.CodDefUsuario__c</formula>
        <name>Atualiza número do banco</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_pais_cob_com_end_usuario</fullName>
        <field>Billing_Country__c</field>
        <formula>IF( NOT(ISBLANK(Shipping_UF__c)), $User.Country,NULL)</formula>
        <name>Atualiza país cob com end usuário</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_pais_com_end_usuario</fullName>
        <field>Revenue_Country__c</field>
        <formula>$User.Country</formula>
        <name>Atualiza país fat com end usuário</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_pais_ent_com_end_usuario</fullName>
        <field>Shipping_Country__c</field>
        <formula>IF( NOT(ISBLANK(Shipping_UF__c)), $User.Country,NULL)</formula>
        <name>Atualiza país ent com end usuário</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_rejei_o_aprova_o</fullName>
        <field>Rejections_Approvals_Numbers__c</field>
        <formula>10</formula>
        <name>Atualiza rejeição/aprovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Em_aprovacao_comercial</fullName>
        <field>Status__c</field>
        <literalValue>Em aprovação  - Comercial</literalValue>
        <name>Atualiza status - Em aprovação comercial</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_uf_faturamento</fullName>
        <field>Revenue_UF__c</field>
        <formula>Revenue_City__r.Descricao2__c</formula>
        <name>Atualiza_uf_faturamento</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Avanca_status_cadastral</fullName>
        <description>Avança o campo da conta STATUS DE CADASTRO para o próximo valor da lista</description>
        <field>Status__c</field>
        <name>Avança status cadastral</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>NextValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Desmarca_Conferido_Adm_vendas</fullName>
        <field>Checked_over_Sales_Administration__c</field>
        <literalValue>0</literalValue>
        <name>Desmarca Conferido – Adm. vendas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Desmarca_Conferido_Credito_e_cobranca</fullName>
        <field>Checked_over_Credit_and_collection__c</field>
        <literalValue>0</literalValue>
        <name>Desmarca Conferido – Crédito e cobrança</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Desmarca_Conferido_Planej_Comercial</fullName>
        <field>Checked_over_Commercial_Planning__c</field>
        <literalValue>0</literalValue>
        <name>Desmarca Conferido – Planej. Comercial</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_ACC_IsInterfaceProcessUpdate</fullName>
        <field>Is_Interface_Process_AR__c</field>
        <literalValue>0</literalValue>
        <name>LAT_ACC_IsInterfaceProcessUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_ACC_UpdateRevenueCountry</fullName>
        <description>Updates the field Revenue Country depending on the Record Type.</description>
        <field>Revenue_Country__c</field>
        <formula>CASE($RecordType.DeveloperName,
       &apos;Eventos&apos;,               &apos;BR&apos;,
       &apos;Off_Trade&apos;,             &apos;BR&apos;,
       &apos;On_Trade&apos;,              &apos;BR&apos;,                                 &apos;LAT_Distribucao_Com_Faturamento&apos;,&apos;BR&apos;,
&apos;LAT_Off_Trade_Sem_Faturamento&apos;,&apos;BR&apos;,
&apos;LAT_Off_Trade_Faturamento&apos;,&apos;BR&apos;,
&apos;LAT_On_Line_Com_Faturamento&apos;,&apos;BR&apos;,
&apos;LAT_On_Trade_Venda_Directa&apos;,&apos;BR&apos;,
&apos;LAT_On_Trade_Sem_Pagamento&apos;,&apos;BR&apos;,
&apos;LAT_On_Trade_Com_Pagamento&apos;,&apos;BR&apos;,
&apos;LAT_Eventos_VendaDirecta&apos;,&apos;BR&apos;,
&apos;LAT_Eventos_com_pagamento&apos;,&apos;BR&apos;,
&apos;LAT_Eventos_sem_pagamento&apos;,&apos;BR&apos;,
       &apos;ACC_1_OffTrade_ARG&apos;,    &apos;AR&apos;,
       &apos;ACC_3_OnTrade_ARG&apos;,     &apos;AR&apos;,
       &apos;ACC_5_Events_ARG&apos;,      &apos;AR&apos;,
       &apos;LAT_AR_Prospect&apos;,      &apos;AR&apos;,
       &apos;ACC_2_OffTrade_URU&apos;,    &apos;UY&apos;,
       &apos;ACC_4_OnTrade_URU&apos;,     &apos;UY&apos;,
       &apos;ACC_6_Events_URU&apos;,      &apos;UY&apos;,
       &apos;LAT_MX_ACC_OffTrade&apos;, &apos;MX&apos;,
       &apos;LAT_MX_ACC_OnTrade&apos;,    &apos;MX&apos;,
       &apos;&apos;
     )</formula>
        <name>LAT_ACC_UpdateRevenueCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_ACC_StatusUpdate10</fullName>
        <description>Updates Status to &apos;Analysis - Sales Manager&apos;</description>
        <field>Status__c</field>
        <literalValue>Analysis - Sales Manager</literalValue>
        <name>LAT_AR_ACC_StatusUpdate10</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_ACC_StatusUpdate11</fullName>
        <description>Updates Status to &apos;Analysis - Commercial Director&apos;</description>
        <field>Status__c</field>
        <literalValue>Analysis - Commercial Director</literalValue>
        <name>LAT_AR_ACC_StatusUpdate11</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_ACC_StatusUpdate12</fullName>
        <description>Updates Status to &apos;Analysis - Financial Director&apos;.</description>
        <field>Status__c</field>
        <literalValue>Analysis - Financial Director</literalValue>
        <name>LAT_AR_ACC_StatusUpdate12</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_ACC_StatusUpdate13</fullName>
        <description>Updates Status to &apos;Analysis - Financial Manager&apos;.</description>
        <field>Status__c</field>
        <literalValue>Analysis - Financial Manager</literalValue>
        <name>LAT_AR_ACC_StatusUpdate13</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_ACC_UpdateStatus14</fullName>
        <field>Status__c</field>
        <literalValue>Customer Sent to JDE - Please Wait</literalValue>
        <name>LAT_AR_ACC_UpdateStatus14</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_ACC_InactivateAccount</fullName>
        <field>Rating</field>
        <literalValue>Cliente inativo</literalValue>
        <name>LAT_BR_ACC_InactivateAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_ACC_TBCI_Approve</fullName>
        <field>Status__c</field>
        <literalValue>Aprovação Financeiro - TBCI</literalValue>
        <name>LAT_BR_ACC_TBCI_Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_ACC_TBCI_Reject</fullName>
        <field>Status__c</field>
        <literalValue>TBCI - Reprovado</literalValue>
        <name>LAT_BR_ACC_TBCI_Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_Status_CadastradoJde</fullName>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no JDE</literalValue>
        <name>LAT_BR_Status_CadastradoJde</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_UpdateRating_Ativo</fullName>
        <field>Rating</field>
        <literalValue>Cliente Ativo</literalValue>
        <name>LAT_BR_UpdateRating_Ativo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_UpdateTBCIAprovado</fullName>
        <field>Status__c</field>
        <literalValue>TBCI - Aprovado</literalValue>
        <name>LAT_BR_UpdateTBCIAprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_UpdateTBCIReprovado</fullName>
        <field>Status__c</field>
        <literalValue>TBCI - Reprovado</literalValue>
        <name>LAT_BR_UpdateTBCIReprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_Update_Status_Cadastrado_CRM</fullName>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no CRM</literalValue>
        <name>Update_Status_Cadastrado_CRM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_UpdatesStatusToCustomerService</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - Customer Service</literalValue>
        <name>LAT_BR_UpdatesStatusToCustomerService</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_UpdatesStatusToCustomerServiceON</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - Customer Service</literalValue>
        <name>LAT_BR_UpdatesStatusToCustomerServiceON</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_APStepInitialUpdate</fullName>
        <description>Sets the field &apos;Ap Step&apos; to 0.</description>
        <field>LAT_MX_APStep__c</field>
        <formula>0</formula>
        <name>LAT_MX_ACC_APStepInitialUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_APStepUpdate</fullName>
        <description>Sums 1 to the  field &apos;Ap Step&apos;.</description>
        <field>LAT_MX_APStep__c</field>
        <formula>LAT_MX_APStep__c + 1</formula>
        <name>LAT_MX_ACC_APStepUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_APStepUpdatex2</fullName>
        <field>LAT_MX_APStep__c</field>
        <formula>LAT_MX_APStep__c + 2</formula>
        <name>LAT_MX_ACC_APStepUpdatex2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_APStepUpdatex5</fullName>
        <field>LAT_MX_APStep__c</field>
        <formula>LAT_MX_APStep__c + 5</formula>
        <name>LAT_MX_ACC_APStepUpdatex5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_CreditLineUpdateTo0</fullName>
        <description>Updates Credit Line to 0 for Mexico when a new record is created if Record Type is Off Trade and Type is different to Pagador.</description>
        <field>Credit_line__c</field>
        <formula>0</formula>
        <name>LAT_MX_ACC_CreditLineUpdateTo0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_CreditLineUpdateTo1</fullName>
        <description>Updates Credit Line to 1 for Mexico when a new record is created if Record Type is Off Trade and Type is Pagador.</description>
        <field>Credit_line__c</field>
        <formula>1</formula>
        <name>LAT_MX_ACC_CreditLineUpdateTo1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_RevenueCountryUpdate</fullName>
        <description>Updates Revenue Country to MX for Mexico</description>
        <field>Revenue_Country__c</field>
        <formula>&apos;MX&apos;</formula>
        <name>LAT_MX_ACC_RevenueCountryUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate0</fullName>
        <description>Updates Status to ‘Em aprovação - Comercial’ for MX.</description>
        <field>Status__c</field>
        <literalValue>Em aprovação  - Comercial</literalValue>
        <name>LAT_MX_ACC_StatusUpdate0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate1</fullName>
        <description>Updates Status to ‘Analysis - Commercial Administration’ for MX.</description>
        <field>Status__c</field>
        <literalValue>Analysis - Commercial Administration</literalValue>
        <name>LAT_MX_ACC_StatusUpdate1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate10</fullName>
        <description>Updates Status to ‘Cliente cadastrado no CRM’ for MX.</description>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no CRM</literalValue>
        <name>LAT_MX_ACC_StatusUpdate10</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate11</fullName>
        <description>Updates Status to &quot;Analysis - Master Data&quot;</description>
        <field>Status__c</field>
        <literalValue>Analysis - Master Data</literalValue>
        <name>LAT_MX_ACC_StatusUpdate11</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate13</fullName>
        <field>Status__c</field>
        <literalValue>Activo MX</literalValue>
        <name>LAT_MX_ACC_StatusUpdate13</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate14</fullName>
        <field>Status__c</field>
        <literalValue>Inactivo MX</literalValue>
        <name>LAT_MX_ACC_StatusUpdate14</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate15</fullName>
        <field>Status__c</field>
        <literalValue>Inactive Approved</literalValue>
        <name>LAT_MX_ACC_StatusUpdate15</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate16</fullName>
        <field>Status__c</field>
        <literalValue>Inactive Rejected</literalValue>
        <name>LAT_MX_ACC_StatusUpdate16</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate2</fullName>
        <description>Updates Status to ‘Analysis - Legal&apos; for MX.</description>
        <field>Status__c</field>
        <literalValue>Analysis - Commercial Control</literalValue>
        <name>LAT_MX_ACC_StatusUpdate2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate3</fullName>
        <description>Updates Status to  ‘Em análise - Crédito e Cobrança’ for MX.</description>
        <field>Status__c</field>
        <literalValue>Em análise - Crédito e Cobrança</literalValue>
        <name>LAT_MX_ACC_StatusUpdate3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate4</fullName>
        <description>Updates Status to &apos;Não aprovado’ for MX.</description>
        <field>Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>LAT_MX_ACC_StatusUpdate4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate5</fullName>
        <description>Updates Status to ‘Not approved by Legal&apos; for MX.</description>
        <field>Status__c</field>
        <literalValue>Not approved by Commercial Control</literalValue>
        <name>LAT_MX_ACC_StatusUpdate5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate6</fullName>
        <description>Updates Status to  ‘Not approved by Credit and Collections&apos; for MX.</description>
        <field>Status__c</field>
        <literalValue>Not approved by Credit and Collections</literalValue>
        <name>LAT_MX_ACC_StatusUpdate6</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate7</fullName>
        <description>Updates Status to ‘Not approved by Commercial Administration’ for MX.</description>
        <field>Status__c</field>
        <literalValue>Not approved by Commercial Administration</literalValue>
        <name>LAT_MX_ACC_StatusUpdate7</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate8</fullName>
        <description>Updates Status to ‘Analysis - Logistics&apos; for MX.</description>
        <field>Status__c</field>
        <literalValue>Analysis - Logistics</literalValue>
        <name>LAT_MX_ACC_StatusUpdate8</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_StatusUpdate9</fullName>
        <description>Updates Status to ‘Directed to be registered In JDE&apos; for MX.</description>
        <field>Status__c</field>
        <literalValue>Directed to be registered In JDE</literalValue>
        <name>LAT_MX_ACC_StatusUpdate9</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_ACC_UpdateStatusForJDE</fullName>
        <field>Status__c</field>
        <literalValue>Modification requested in CRM</literalValue>
        <name>LAT_MX_ACC_UpdateStatusForJDE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_Account_OnTradeApproved</fullName>
        <field>Status__c</field>
        <literalValue>Directed to be registered In JDE</literalValue>
        <name>LAT_MX_Account_OnTradeApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_Account_OnTradeRejected</fullName>
        <field>Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>LAT_MX_Account_OnTradeRejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_Account_OnTradeSendApproved</fullName>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no CRM</literalValue>
        <name>LAT_MX_Account_OnTradeSendApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_Set_Status</fullName>
        <field>Status__c</field>
        <literalValue>Em análise - Customer Service</literalValue>
        <name>Set Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Numero_da_Transportadora</fullName>
        <description>Atualiza o numero da transportadora de acordo com a unidade de negocio selecionada.</description>
        <field>Carriers_Numbers__c</field>
        <formula>if( Business_Unit__r.CodDefUsuario__c = &quot;05&quot;, &quot;16612&quot;,
if( Business_Unit__r.CodDefUsuario__c = &quot;03&quot;, &quot;146146&quot;,
if( Business_Unit__r.CodDefUsuario__c = &quot;10&quot;, &quot;149146&quot;,
if( Business_Unit__r.CodDefUsuario__c = &quot;17&quot;, &quot;149146&quot;,&quot;&quot;))))</formula>
        <name>Numero_da_Transportadora</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRevenueCountry</fullName>
        <field>Revenue_Country__c</field>
        <formula>IF( UPPER($User.Country) = UPPER(&apos;Argentina&apos;)  ,    &apos;AR&apos;   ,       IF( UPPER($User.Country) = UPPER(&apos;Uruguay&apos;) , &apos;UY&apos;, &apos;&apos;)    )</formula>
        <name>UpdateRevenueCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Custom_1_with_Corby_Neutral_Comp</fullName>
        <field>gvp__Custom_1__c</field>
        <formula>Text( Corby_Neutral_Comp_CA__c)</formula>
        <name>Update Custom 1 with Corby_Neutral_Comp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Cadastrado_CRM</fullName>
        <field>Status__c</field>
        <literalValue>Cliente cadastrado no CRM</literalValue>
        <name>Update_Status_Cadastrado_CRM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Zera_rejeicao_aprovacao</fullName>
        <field>Rejections_Approvals_Numbers__c</field>
        <formula>-1</formula>
        <name>Zera rejeição/aprovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ACC_WF01_UpdateCreditLine_AR</fullName>
        <actions>
            <name>ACC_UpdateCreditLineTo1_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the field ParentId is empty and the field Type is &quot;No Charge_ARG&quot; updates the field Credit_line to &quot;1&quot;</description>
        <formula>( $RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos; )  &amp;&amp; ( ISBLANK(ParentId) &amp;&amp; ISPICKVAL(Type,&quot;No Charge_ARG&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF02_UpdateCreditLine_AR</fullName>
        <actions>
            <name>ACC_UpdateCreditLineTo0_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the client is a child with revenue UF different from 1 and revenue country different from AR or the field Type is &quot;Prospect_ARG&quot;, &quot;Indirect_ARG&quot; or &quot;Events_ARG&quot; updates the field Credit_line to &quot;0&quot;</description>
        <formula>( $RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos; )  &amp;&amp;  (NOT(ISBLANK(ParentId)) ||  (  ISPICKVAL(Type,&quot;Prospect_ARG&quot;) || ISPICKVAL(Type,&quot;Indirect_ARG&quot;) || ISPICKVAL(Type,&quot;Events_ARG&quot;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF03_EmailAlertJDEerror_ARG</fullName>
        <actions>
            <name>ACC_ErrorInJDE_AR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email alert when status equals error in JDE.</description>
        <formula>($RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos;) &amp;&amp;    ISPICKVAL(Status__c , &quot;Erro JDE&quot;) &amp;&amp;  ISCHANGED(Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF03_EmailAlertJDEerror_UY</fullName>
        <actions>
            <name>ACC_ErrorInJDE_UY</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email alert when status equals error in JDE.</description>
        <formula>($RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos; ) &amp;&amp;   ISBLANK(PRIORVALUE(Return_JDE_Integration__c)) &amp;&amp;   NOT(ISBLANK(Return_JDE_Integration__c) ) &amp;&amp; ISPICKVAL(Status__c , &quot;Erro JDE&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF04_UpdateRating_AR</fullName>
        <actions>
            <name>ACC_RatingUpdate5_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF05_UpdateRevenueUF_AR</fullName>
        <actions>
            <name>ACC_RevenueUFUpdate_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF06_UpdateTriggerRun_AR</fullName>
        <actions>
            <name>ACC_UpdateTriggerRun_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos;  || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos;  || $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos; ) &amp;&amp; TriggerRun__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF09_UpdateRevenueNeighbourhood_AR</fullName>
        <actions>
            <name>ACC_UpdateNeighbourhood_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Cuando se complete el campo Revenue City del cliente, el sistema copia el valor del campo RevenueCity Name al campo Revenue Neighbourhood.</description>
        <formula>($RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos; ) &amp;&amp; (Revenue_City__c  != null)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WF10_UpdateIsInterfaceProcess_AR</fullName>
        <actions>
            <name>ACC_IsInterfaceProcessUpdate_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Is_Interface_Process_AR__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI HK CRM Add Cust No%2E Potential Acct Name</fullName>
        <actions>
            <name>ASI_HK_CRM_Append_Cust_Num_to_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Potential Account (HK)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Potential Account - Prestige (HK)</value>
        </criteriaItems>
        <description>Appends ASI_HK_CRM_Customer_Number__c to Account Name for HK CRM and LUX Potential Accounts</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX - Scheduled Anniversary Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_Next_Anniversary_Date__pc</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI Luxury</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ASI_LUX_Le_Cercle_Member__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_LUX_Anniversary_Reminder_for_PR_LUX</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.ASI_LUX_Next_Anniversary_Date__pc</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI LUX - Scheduled Birthday Reminder</fullName>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 6) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Account.ASI_LUX_Next_Birthday__pc</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>contains</operation>
            <value>ASI Luxury</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IsPersonAccount</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ASI_LUX_Birthday_Day__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>ASI Luxury Account (TW) - First Contact,ASI Luxury Account (TW) - Potential,ASI Luxury Account (TW) - Second Contact (Le Cercle Locked),ASI Luxury Account (TW) - Second Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>contains</operation>
            <value>ASI Brand</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_LUX_Birthday_EmailAlert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.ASI_LUX_Next_Birthday__pc</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI LUX - Scheduled Clear Next Anniversary Day</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_Le_Cercle_Member__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI Luxury</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ASI_LUX_Next_Anniversary_Date__pc</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_LUX_Clear_Next_Anniversary_Day</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.ASI_LUX_Next_Anniversary_Date__pc</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI LUX - Scheduled Clear Next Birthday</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.IsPersonAccount</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI Luxury</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ASI_LUX_Next_Birthday__pc</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_LUX_Clear_Next_Birthday</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.ASI_LUX_Next_Birthday__pc</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI LUX - Set Le Cercle Membership Details</fullName>
        <actions>
            <name>ASI_LUX_HK_Check_Le_Cercle_Member</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Appl_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <description>Executes when Approver manually changes the value of Le Cercle Member Applicatoin Status to Approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX - Set Le Cercle Submission Date</fullName>
        <actions>
            <name>ASI_LUX_HK_Set_Submission_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Appl_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX - Set Next Anniversary Date</fullName>
        <actions>
            <name>ASI_LUX_Set_Next_Anniversary_Day</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Since_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI Luxury</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ASI_LUX_Next_Anniversary_Date__pc</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX Change Person Account Record Type to First Contact</fullName>
        <actions>
            <name>ASI_LUX_Set_RecordType_First_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (HK) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Change Person Account Record Type to First Contact</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX Change Person Account Record Type to Second Contact</fullName>
        <actions>
            <name>ASI_LUX_Update_Record_Type_2nd_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>Second Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (HK) - First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (HK) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Change Person Account Record Type to Second Contact</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX HK - Set 2nd Contact Le Cercle Locked</fullName>
        <actions>
            <name>ASI_LUX_HK_Set_Le_Cercle_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Appl_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (HK) - Second Contact</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX MY - Set 2nd Contact Le Cercle Locked</fullName>
        <actions>
            <name>ASI_LUX_MY_Set_Le_Cercle_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Appl_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (MY) - Second Contact</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX MY Change Person Account Record Type to First Contact</fullName>
        <actions>
            <name>ASI_LUX_Set_RecordType_First_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (MY) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Change Person Account Record Type to First Contact MY</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX MY Change Person Account Record Type to Second Contact</fullName>
        <actions>
            <name>ASI_LUX_MY_Update_Record_2nd_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>Second Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (MY) - First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (MY) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Change Person Account Record Type to Second Contact MY</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX REG - Set 2nd Contact Le Cercle Locked</fullName>
        <actions>
            <name>ASI_LUX_Reg_Set_Le_Cercle_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Appl_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (Regional) - Second Contact</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX REG Change Person Account Record Type to First Contact</fullName>
        <actions>
            <name>ASI_LUX_REG_Set_RecordType_First_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (Regional) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Regional - Change Person Account Record Type to First Contact</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX REG Change Person Account Record Type to Second Contact</fullName>
        <actions>
            <name>ASI_LUX_REG_Update_RecordType_2ndContact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>Second Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (Regional) - First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (Regional) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Regional - Change Person Account Record Type to Second Contact</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX SG - Set 2nd Contact Le Cercle Locked</fullName>
        <actions>
            <name>ASI_LUX_SG_Set_Le_Cercle_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Appl_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (SG) - Second Contact</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX SG Change Person Account Record Type to Second Contact</fullName>
        <actions>
            <name>ASI_LUX_SG_Update_Record_2nd_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>Second Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (SG) - First Contact</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX TW - Set 2nd Contact Le Cercle Locked</fullName>
        <actions>
            <name>ASI_LUX_TW_Set_Le_Cercle_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_LeCercle_Member_Appl_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (TW) - Second Contact</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX TW Change Person Account Record Type to First Contact</fullName>
        <actions>
            <name>ASI_LUX_TW_Set_RecordType_First_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (TW) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Change Person Account Record Type to First Contact TW</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX TW Change Person Account Record Type to Second Contact</fullName>
        <actions>
            <name>ASI_LUX_TW_Update_Record_2nd_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Account.ASI_LUX_Profile__c</field>
            <operation>equals</operation>
            <value>Second Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (TW) - First Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Luxury Account (TW) - Potential</value>
        </criteriaItems>
        <description>ASI LUX Change Person Account Record Type to Second Contact TW</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_BRD_Copy_to_PersonHomePhone</fullName>
        <actions>
            <name>ASI_BRD_Copy_Home_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(BEGINS(RecordType.DeveloperName, &apos;ASI_LUX&apos;), BEGINS(RecordType.DeveloperName, &apos;ASI_BRD_&apos;)) &amp;&amp; !ISBLANK(ASI_BRD_Home_Phone__pc) &amp;&amp; ISBLANK(PersonHomePhone)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_BRD_SG_Upgrade_To_Luxury_Record_Type</fullName>
        <actions>
            <name>ASI_BRD_SG_Convert_SG_LUX_First_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Brand TGL Account (SG)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Brand GHM Account (SG)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ASI_BRD_Sys_Upgrade_from_Brand_to_Luxury__pc</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_BRD_SG_Upgrade_to_Luxury_Update_Fields</fullName>
        <actions>
            <name>ASI_BRD_SG_Set_English_PreferredLang1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Brand TGL Account (SG)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Brand GHM Account (SG)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ASI_BRD_Sys_Upgrade_from_Brand_to_Luxury__pc</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_BRD_Update_OtherBrand1_Engaged</fullName>
        <actions>
            <name>ASI_BRD_Update_OtherBrand1_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>BEGINS(RecordType.DeveloperName,&apos;ASI_BRD_&apos;) &amp;&amp; OR (ISPICKVAL(ASI_BRD_Primary_Market__pc, &apos;Taiwan&apos;), ISPICKVAL(ASI_BRD_Primary_Market__pc, &apos;Singapore&apos;), ISPICKVAL(ASI_BRD_Primary_Market__pc, &apos;Malaysia&apos;)) &amp;&amp; INCLUDES(ASI_BRD_Brands_Engaged__pc, &apos;Aberlour&apos;) &amp;&amp; ISCHANGED(ASI_BRD_Brands_Engaged__pc)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_BRD_Update_OtherBrand2_Engaged</fullName>
        <actions>
            <name>ASI_BRD_Update_OtherBrand2_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>BEGINS(RecordType.DeveloperName,&apos;ASI_BRD_&apos;) &amp;&amp; OR (ISPICKVAL(ASI_BRD_Primary_Market__pc, &apos;Taiwan&apos;), ISPICKVAL(ASI_BRD_Primary_Market__pc, &apos;Singapore&apos;), ISPICKVAL(ASI_BRD_Primary_Market__pc, &apos;Malaysia&apos;)) &amp;&amp; INCLUDES(ASI_BRD_Brands_Engaged__pc, &quot;Jacob&apos;s Creek&quot;)&amp;&amp;  ISCHANGED(ASI_BRD_Brands_Engaged__pc)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_BRD_Update_OtherBrand3_Engaged</fullName>
        <actions>
            <name>ASI_BRD_Update_OtherBrand3_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>BEGINS(RecordType.DeveloperName,&apos;ASI_BRD_&apos;) &amp;&amp; ISPICKVAL(ASI_BRD_Primary_Market__pc, &apos;Malaysia&apos;) &amp;&amp; INCLUDES(ASI_BRD_Brands_Engaged__pc, &apos;Wyndham Estate&apos;)&amp;&amp;  ISCHANGED(ASI_BRD_Brands_Engaged__pc)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Altera classificação do cliente</fullName>
        <actions>
            <name>Atualiza_classificacao_Cliente</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $RecordType.DeveloperName=&apos;Eventos&apos;  || $RecordType.DeveloperName=&apos;Off_Trade&apos;  || $RecordType.DeveloperName=&apos;On_Trade&apos; )  &amp;&amp;   (ISPICKVAL( Status__c, &quot;,Cliente cadastrado no JDE&quot;) &amp;&amp;  ISPICKVAL(  Channel__c , &quot;,Off Trade&quot;) &amp;&amp;  NOT(ISPICKVAL ( Rating ,&quot;Cliente inativo&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Atualiza campo numero da transportadora</fullName>
        <actions>
            <name>Numero_da_Transportadora</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $RecordType.DeveloperName=&apos;Eventos&apos;  || $RecordType.DeveloperName=&apos;LAT_Distribucao_Com_Faturamento&apos;  ||  $RecordType.DeveloperName=&apos;LAT_Off_Trade_Sem_Faturamento&apos;  ||  $RecordType.DeveloperName=&apos;LAT_Off_Trade_Faturamento&apos;  ||  $RecordType.DeveloperName=&apos;LAT_On_Line_Com_Faturamento&apos;  ||  $RecordType.DeveloperName=&apos;LAT_On_Trade_Venda_Directa&apos;  ||  $RecordType.DeveloperName=&apos;LAT_On_Trade_Sem_Pagamento&apos;  ||  $RecordType.DeveloperName=&apos;LAT_On_Trade_Com_Pagamento&apos;  ||  $RecordType.DeveloperName=&apos;LAT_Eventos_VendaDirecta&apos;  ||  $RecordType.DeveloperName=&apos;LAT_Eventos_com_pagamento&apos;  ||  $RecordType.DeveloperName=&apos;LAT_Eventos_sem_pagamento&apos;  ||  $RecordType.DeveloperName=&apos;On_Trade&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Conferido - Adm vendas</fullName>
        <actions>
            <name>Altera_status_Em_Analise_CeC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $RecordType.DeveloperName=&apos;Eventos&apos;  || $RecordType.DeveloperName=&apos;Off_Trade&apos;  /*|| $RecordType.DeveloperName=&apos;On_Trade&apos;*/ ) &amp;&amp;  (Checked_over_Sales_Administration__c = true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Conferido - Planej Comercial</fullName>
        <actions>
            <name>Altera_status_Em_aprova_o_financeiro</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $RecordType.DeveloperName=&apos;Eventos&apos;  || $RecordType.DeveloperName=&apos;Off_Trade&apos;  || $RecordType.DeveloperName=&apos;On_Trade&apos; )  &amp;&amp;  (Checked_over_Commercial_Planning__c = true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Envia alteração de cad para o JDE</fullName>
        <actions>
            <name>Altera_status_Aprov_cadastro_no_JDE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $RecordType.DeveloperName=&apos;Eventos&apos;  || $RecordType.DeveloperName=&apos;Off_Trade&apos;  || $RecordType.DeveloperName=&apos;On_Trade&apos; )  &amp;&amp; (AND( ($Profile.Name = &quot;Controladoria&quot; || $Profile.Name = &quot;LAT_BR2_Controladoria&quot;),          OR(                ISPICKVAL( Status__c, &quot;Cliente cadastrado no JDE&quot;),                 ISPICKVAL( Status__c, &quot;Erro JDE&quot;)),          OR(                ISPICKVAL( PRIORVALUE(Status__c),&quot;Cliente cadastrado no JDE&quot; ),                ISPICKVAL( PRIORVALUE(Status__c),&quot;Erro JDE&quot; ))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_ACC_WF01_UpdateIsInterfaceProcess</fullName>
        <actions>
            <name>LAT_ACC_IsInterfaceProcessUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the field Is Interface Process to false</description>
        <formula>( $RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos; ||  $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos; ||  $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos; || $RecordType.DeveloperName=&apos;LAT_MX_ACC_OffTrade&apos; || $RecordType.DeveloperName=&apos;LAT_MX_ACC_OnTrade&apos; ) &amp;&amp; Is_Interface_Process_AR__c = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_ACC_WF02_UpdateRevenueCountry</fullName>
        <actions>
            <name>LAT_ACC_UpdateRevenueCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the field Revenue_Country__c with the Country abbreviation according to the Record Type of the record.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_AR_AC_UpdateCustomerSent</fullName>
        <actions>
            <name>LAT_AR_ACC_UpdateStatus14</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Status to &quot;Customer Sent To JDE&quot;</description>
        <formula>($RecordType.DeveloperName=&apos;ACC_1_OffTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_3_OnTrade_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_5_Events_ARG&apos; || $RecordType.DeveloperName=&apos;ACC_2_OffTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_4_OnTrade_URU&apos; || $RecordType.DeveloperName=&apos;ACC_6_Events_URU&apos;) &amp;&amp; ISPICKVAL(Status__c, &apos;Directed to be registered In JDE&apos;) &amp;&amp; (ISPICKVAL(Rating, &apos;Cliente&apos;) || ISPICKVAL(Rating, &apos;Cliente inativo&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LAT_BR_ACC_NotifiesComercialPlanning</fullName>
        <actions>
            <name>LAT_BR_ACC_NotifiesComercialPlanning</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email to all the users in the Commercial Planning group when a client AN8 is received from JDE</description>
        <formula>$RecordType.DeveloperName=&apos;Off_Trade&apos; &amp;&amp;  NOT(ISBLANK( Client_code_AN8__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_ACC_WF02_UpdateCreditLineTo1</fullName>
        <actions>
            <name>LAT_MX_ACC_CreditLineUpdateTo1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Credit Line to 0 for Mexico when a new record is created if Record Type is Off Trade and Type is different to Pagador.</description>
        <formula>$RecordType.DeveloperName=&apos;LAT_MX_ACC_OffTrade&apos; &amp;&amp; ISPICKVAL(Type,&apos;Payer&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_ACC_WF03_UpdateCreditLineTo0</fullName>
        <actions>
            <name>LAT_MX_ACC_CreditLineUpdateTo0</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Credit Line to 0 for Mexico when a new record is created if Record Type is Off Trade and Type is different to Pagador.</description>
        <formula>$RecordType.DeveloperName=&apos;LAT_MX_ACC_OffTrade&apos;  &amp;&amp; NOT(ISPICKVAL(Type,&apos;Payer&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_ACC_WF04_UpdateStatusForJDE</fullName>
        <actions>
            <name>LAT_MX_ACC_UpdateStatusForJDE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Status to &apos;Modification requested in CRM&apos; when Status is &apos;Cliente cadastrado no JDE&apos; and a field that is mapped with JDE is updated.</description>
        <formula>($RecordType.DeveloperName=&apos;LAT_MX_ACC_OffTrade&apos; || $RecordType.DeveloperName=&apos;LAT_MX_ACC_OnTrade&apos; ) &amp;&amp; Is_Interface_Process_AR__c = false &amp;&amp; (ISPICKVAL(Status__c,&apos;Cliente cadastrado no JDE&apos;) || ISPICKVAL(Status__c,&apos;Erro JDE&apos;) ) &amp;&amp; (ISPICKVAL(Type,&apos;Payer&apos;) || ISPICKVAL(Type,&apos;Consignee&apos;) ) &amp;&amp; ( ISCHANGED(OwnerId) || ISCHANGED(Corporate_Name__c) || ISCHANGED(Sub_Channel_Rating__c) || ISCHANGED(Segmentation_Type_on_trade__c) || ISCHANGED(CNPJ__c) || ISCHANGED(LAT_MX_FiscalEntityType__c) || ISCHANGED(Credit_line__c) || ISCHANGED(Client_code_AN8__c) || ISCHANGED(Accept_applications_Incompleted__c) || ISCHANGED(Accept_line_incompleted__c) || ISCHANGED(Accept_Backorder__c) || ISCHANGED(CustomerPriceGroup_AR__c) || ISCHANGED(AddressLine1_AR__c) || ISCHANGED(Revenue_Country__c) || ISCHANGED(LAT_MX_City__c) || ISCHANGED(LAT_MX_Neighbourhood__c) || ISCHANGED(LAT_MX_State__c) || ISCHANGED(LAT_MX_County__c) || ISCHANGED(LAT_MX_PostalCode__c) ||  ISCHANGED(Revenue_Number__c) || ISCHANGED(Channel__c) || ISCHANGED(AccountNumber) || ISCHANGED(Billing_Priority__c) || ISCHANGED(LAT_MX_Language__c) || ISCHANGED(LAT_MX_CableCodeS__c) || ISCHANGED(LAT_MX_RelatedAddressAN8__c)|| ISCHANGED(LAT_MX_Market__c) || ISCHANGED(Customer_Geographic_Region__c) || ISCHANGED(Payment_Condition__c) || ISCHANGED(Payment_instrument__c) || ISCHANGED(Customer_GL__c) || ISCHANGED(LAT_MX_ABCCode__c) || ISCHANGED(LAT_MX_RouteCode__c) || ISCHANGED(LAT_MX_BatchProcess__c) || ISCHANGED(LAT_MX_ZoneNumber__c) || ISCHANGED(LAT_MX_Chain__c) || ISCHANGED(LAT_MX_FiscalRate__c) || ISCHANGED(LAT_MX_CreditVersionLevel__c) || ISCHANGED(ParentId) || ISCHANGED(LAT_MX_AmountReceiptCopies__c) || ISCHANGED(LAT_MX_Group__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_ACC_WF05_JDE IntegrationErrorNotification</fullName>
        <actions>
            <name>LAT_MX_ACC_AccountErrorJDEEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends an e-mail alert to Group &apos;LAT_MX - JDE Integration Error Notif&apos; everytime the Account Status is &apos;Erro JDE&apos;</description>
        <formula>($RecordType.DeveloperName=&apos;LAT_MX_ACC_OffTrade&apos; || $RecordType.DeveloperName=&apos;LAT_MX_ACC_OnTrade&apos; ) &amp;&amp; ISPICKVAL(Status__c,&apos;Erro JDE&apos;) &amp;&amp; NOT(ISPICKVAL(PRIORVALUE(Status__c),&apos;Erro JDE&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Put Corby_Neutral_Comp in Custom 1</fullName>
        <actions>
            <name>Update_Custom_1_with_Corby_Neutral_Comp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Novo_cadastro_de_cliente_rejeitado</fullName>
        <assignedToType>owner</assignedToType>
        <description>Prezado(a)

O cadastro do novo cliente foi rejeitado no processo de aprovação, para maiores detalhes ou correções do mesmo, clique no nome do cliente.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Novo cadastro de cliente rejeitado</subject>
    </tasks>
    <tasks>
        <fullName>teste</fullName>
        <assignedToType>owner</assignedToType>
        <description>teste</description>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>teste</subject>
    </tasks>
</Workflow>
