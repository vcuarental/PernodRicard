<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PLC_ApprovalEmailAlert_UY</fullName>
        <description>PLC_ApprovalForNewVisitPlanningRecord_UY</description>
        <protected>false</protected>
        <recipients>
            <recipient>KAM_Users_AR</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PLC_ApprovalForNewVisitPlanningRecord_AR</template>
    </alerts>
    <fieldUpdates>
        <fullName>Aprova_o_semana_2</fullName>
        <field>Aprovado_semana_2__c</field>
        <literalValue>1</literalValue>
        <name>Aprovação semana 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Aprova_o_semana_3</fullName>
        <field>Aprovado_semana_3__c</field>
        <literalValue>1</literalValue>
        <name>Aprovação semana 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Aprova_o_semana_4</fullName>
        <field>aprovado_semana_4__c</field>
        <literalValue>1</literalValue>
        <name>Aprovação semana 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Aprova_planejamento_semana_1</fullName>
        <field>Aprovado_semana_1__c</field>
        <literalValue>1</literalValue>
        <name>Aprova planejamento semana 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_PLV_MonthYearUserUpdate1</fullName>
        <field>Month_Year_User__c</field>
        <formula>TEXT(M_s_de_Ref_rencia__c)+TEXT(Ano_de_Referencia__c)+OwnerId</formula>
        <name>LAT_AR_PLV_MonthYearUserUpdate1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_PLV_UpdatesStatusToApproved</fullName>
        <description>Updates status to Approved</description>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Approved</literalValue>
        <name>LAT_BR_PLV_UpdatesStatusToApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_PLV_MonthYearUserUpdate</fullName>
        <description>Updates field Month Year User</description>
        <field>Month_Year_User__c</field>
        <formula>TEXT(M_s_de_Ref_rencia__c)+TEXT(Ano_de_Referencia__c)+OwnerId</formula>
        <name>LAT_MX_PLV_MonthYearUserUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_PLV_UpdatesRT</fullName>
        <description>Updates Record Type to &apos;LAT_MX_PLV_Approved&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>LAT_MX_PLV_Approved</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>LAT_MX_PLV_UpdatesRT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_PLV_UpdatesStatus</fullName>
        <description>Updates Status of Planejamento to &apos;Aguardando Aprovação&apos;</description>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Aguardando Aprovação</literalValue>
        <name>LAT_MX_PLV_UpdatesStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_PLV_UpdatesStatus2</fullName>
        <description>Updates Status of Planejamento to &apos;Approved&apos;</description>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Approved</literalValue>
        <name>LAT_MX_PLV_UpdatesStatus2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_PLV_UpdatesStatus3</fullName>
        <description>Updates Status of Planejamento to &apos;Modification proposed&apos;</description>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Modification proposed</literalValue>
        <name>LAT_MX_PLV_UpdatesStatus3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PLV_UpdateStatusAprove_AR</fullName>
        <description>Update status to aprove when manager aprove.</description>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Approved</literalValue>
        <name>PLV_UpdateStatusAprove_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PLV_UpdateStatusRejected_AR</fullName>
        <description>Update status to rejected</description>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Rejeitado (Aprovação Mensal)</literalValue>
        <name>PLV_UpdateStatusRejected_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PLV_UpdateStatus_AR</fullName>
        <description>Cambia el status a &apos;aguardando aprovacion&apos;.</description>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Aguardando Aprovação</literalValue>
        <name>PLV_UpdateStatus_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejeitado_02_semana</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Rejeitado Revisão Segunda Semana</literalValue>
        <name>Rejeitado 02 semana</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejeitado_03_semana</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Rejeitado Revisão Terceira Semana</literalValue>
        <name>Rejeitado 03 semana</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejeitado_04_semana</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Rejeitado Revisão Quarta Semana</literalValue>
        <name>Rejeitado 04 semana</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejeitado_mensal</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Rejeitado (Aprovação Mensal)</literalValue>
        <name>Rejeitado mensal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>aprovacao_2</fullName>
        <field>Aprovado_semana_2__c</field>
        <literalValue>1</literalValue>
        <name>aprovacao 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>aprovacao_3</fullName>
        <field>Aprovado_semana_3__c</field>
        <literalValue>1</literalValue>
        <name>aprovacao 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>aprovacao_4</fullName>
        <field>aprovado_semana_4__c</field>
        <literalValue>1</literalValue>
        <name>aprovacao 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>aprovado_03_semana</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Aprovado 03 Semana</literalValue>
        <name>aprovado 03 semana</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>aprovado_semana01</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Aprovado Mensal + 01 Semana</literalValue>
        <name>aprovado semana01</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>atualiza_1_aprovacao</fullName>
        <field>Aprovado_semana_1__c</field>
        <literalValue>1</literalValue>
        <name>atualiza 1 aprovacao</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>atualiza_ipara_encerrado</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Encerrado</literalValue>
        <name>atualiza para encerrado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>atualiza_para_encerrado</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Encerrado</literalValue>
        <name>atualiza para encerrado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>atualiza_status_planejamento_Em_aprova</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Aguardando Aprovação</literalValue>
        <name>atualiza status planejamento Em aprova</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>status_aprovado_02_semana</fullName>
        <field>Status_do_Planejamento__c</field>
        <literalValue>Aprovado 02 Semana</literalValue>
        <name>status aprovado 02 semana</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_AR_PLV_WF01_UniqueMonthYearUser</fullName>
        <actions>
            <name>LAT_AR_PLV_MonthYearUserUpdate1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LAT_MX_PLV_MonthYearUserUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( ($RecordType.DeveloperName=&apos;PLV_Standard_AR&apos;)||($RecordType.DeveloperName=&apos;PLV_Standard_UY&apos;) || ($RecordType.DeveloperName = &apos;LAT_MX_PLV_NewPlanning&apos;) ) &amp;&amp; (     (ISCHANGED(M_s_de_Ref_rencia__c)||ISCHANGED(Ano_de_Referencia__c)||ISCHANGED(OwnerId))     ||     ISNEW()     ||     ISBLANK(Month_Year_User__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
